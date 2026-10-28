#!/usr/bin/env bash
# Start hyprlock and, while it runs, unlock it with a YubiKey touch.
# hyprlock's own PAM check of the key runs once at start, so it misses a key
# plugged in later or reset by suspend; this retries whenever udev adds a FIDO key.

pidof hyprlock >/dev/null && exit 0

# Always unlock in English: switch to layout 0 (us) before locking
niri msg action switch-layout 0
hyprlock &
lock=$!

# Wait for a touch while the key stays plugged in (pam_u2f gives up after ~30 s).
# Succeeds once unlocked or hyprlock is gone; fails when the key is pulled.
try_unlock() {
    while kill -0 "$lock" 2>/dev/null; do
        [[ -n $(fido2-token -L 2>/dev/null) ]] || return 1
        ~/.config/hypr/scripts/u2f-auth.py &
        wait $! && { kill -USR1 "$lock"; return 0; }
        sleep 1
    done
}

# Subscribe before the first check so a key plugged in right now isn't missed
exec {events}< <(udevadm monitor --udev --property --subsystem-match=hidraw)
monitor=$!
# Once hyprlock exits (e.g. unlocked with the password), stop listening and
# drop a pending key check
{ tail --pid="$lock" -f /dev/null; kill "$monitor"; pkill -P $$ -f u2f-auth.py; } &

if ! try_unlock; then
    while read -r -u "$events" line; do
        case $line in
            ACTION=*) action=${line#ACTION=} ;;
            ID_FIDO_TOKEN=1) [[ $action == add ]] && try_unlock && break ;;
        esac
    done
fi
kill "$monitor" 2>/dev/null
wait "$lock"
