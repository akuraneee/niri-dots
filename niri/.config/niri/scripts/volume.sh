#!/usr/bin/env bash
# Change the output volume and show the new level as a notification
# with a progress bar. Usage: volume.sh up|down|mute

sink=@DEFAULT_AUDIO_SINK@

case "$1" in
    up)   wpctl set-mute "$sink" 0; wpctl set-volume "$sink" 0.02+ ;;
    down) wpctl set-volume "$sink" 0.02- ;;
    mute) wpctl set-mute "$sink" toggle ;;
    *)    echo "usage: $0 up|down|mute" >&2; exit 1 ;;
esac

# "Volume: 0.45" or "Volume: 0.45 [MUTED]"
state=$(wpctl get-volume "$sink")
percent=$(awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$state")

if [[ $state == *MUTED* ]]; then
    icon=audio-volume-muted-symbolic
    body="Muted"
elif (( percent < 34 )); then
    icon=audio-volume-low-symbolic
    body="Volume $percent%"
elif (( percent < 67 )); then
    icon=audio-volume-medium-symbolic
    body="Volume $percent%"
else
    icon=audio-volume-high-symbolic
    body="Volume $percent%"
fi

# The synchronous hint makes swaync replace the previous popup instead of stacking;
# the value hint renders as a progress bar
notify-send -a "Volume" -i "$icon" -t 1500 -u low \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:"$([[ $state == *MUTED* ]] && echo 0 || echo "$percent")" \
    "$body"
