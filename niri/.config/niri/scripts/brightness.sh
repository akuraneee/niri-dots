#!/usr/bin/env bash
# Change the screen brightness and show the new level as a notification
# with a progress bar. Usage: brightness.sh up|down

case "$1" in
    up)   brightnessctl -q set 5%+ ;;
    down) brightnessctl -q -n1 set 5%- ;;  # -n1 keeps the screen from going fully dark
    *)    echo "usage: $0 up|down" >&2; exit 1 ;;
esac

percent=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))

# The synchronous hint makes swaync replace the previous popup instead of stacking;
# the value hint renders as a progress bar
notify-send -a "Brightness" -i "display-brightness-symbolic" -t 1500 -u low \
    -h string:x-canonical-private-synchronous:brightness \
    -h int:value:"$percent" \
    "Brightness $percent%"
