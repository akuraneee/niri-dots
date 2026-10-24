#!/usr/bin/env bash
# Switch the power-profiles-daemon profile and confirm with a notification.
# Usage: power-profile.sh performance|balanced|power-saver

case "$1" in
    performance) name="Performance" ;;
    balanced)    name="Balanced" ;;
    power-saver) name="Power saver" ;;
    *) echo "usage: $0 performance|balanced|power-saver" >&2; exit 1 ;;
esac

powerprofilesctl set "$1" || exit 1

# The synchronous hint makes swaync replace the previous popup instead of stacking
notify-send -a "Power" -i "power-profile-$1-symbolic" -t 1500 -u low \
    -h string:x-canonical-private-synchronous:power-profile \
    "Power mode: $name"
