#!/usr/bin/env bash
# Caffeine: keep the screen on and the laptop awake.
#   caffeine.sh          toggle and show a notification
#   caffeine.sh status   JSON for the waybar "custom/caffeine" module
#
# Holds a systemd "idle" inhibitor lock; hypridle honours it, so none of its
# timers (monitors off, lock, suspend) fire while caffeine is on.

pidfile="${XDG_RUNTIME_DIR:-/tmp}/caffeine.pid"
running() { [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; }

if [ "$1" = "status" ]; then
    # Empty text hides the module while caffeine is off
    if running; then
        echo '{"text": "󰅶", "tooltip": "Caffeine on: the screen stays on", "class": "on"}'
    else
        echo '{"text": ""}'
    fi
    exit 0
fi

if running; then
    pid=$(cat "$pidfile")
    kill "$pid"
    # Wait for the lock to go away, otherwise waybar can still see it running
    while kill -0 "$pid" 2>/dev/null; do sleep 0.05; done
    rm -f "$pidfile"
    summary="Caffeine off"
    icon="night-light-disabled-symbolic"
else
    # exec keeps the PID: the inhibitor is the background process itself
    setsid bash -c 'exec systemd-inhibit --what=idle --who=caffeine \
        --why="Caffeine mode" --mode=block sleep infinity' >/dev/null 2>&1 &
    echo $! > "$pidfile"
    summary="Caffeine on"
    icon="night-light-symbolic"
fi

# Refresh the waybar module ("signal": 8)
pkill -RTMIN+8 waybar

notify-send -a "Caffeine" -i "$icon" -t 1500 -u low \
    -h string:x-canonical-private-synchronous:caffeine \
    "$summary"
