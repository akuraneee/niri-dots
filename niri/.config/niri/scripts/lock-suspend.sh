#!/usr/bin/env bash
# Lock the session, wait for hyprlock to cover the screen, then suspend.
# hypridle's before_sleep_cmd can't do this on niri: it doesn't wait for the
# lock, so the desktop flashes on wake until hyprlock catches up.
# Usage: lock-suspend.sh [lid]   (lid: do nothing if an external monitor is connected)

if [[ $1 == lid ]] && (( $(niri msg outputs | grep -c '^Output') > 1 )); then
    exit 0
fi

loginctl lock-session
for _ in {1..30}; do
    pidof hyprlock >/dev/null && break
    sleep 0.1
done
# Let hyprlock take the session lock and draw its first frame
sleep 1
systemctl suspend
