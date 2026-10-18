#!/usr/bin/env bash
# Toggle the default microphone and show a notification with the new state.
# The waybar "pulseaudio#mic" module picks up the change by itself.

# Read the state first and set it explicitly: get-volume right after
# "set-mute toggle" can still report the old state
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
    summary="Microphone on"
    icon="microphone-sensitivity-high-symbolic"
else
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
    summary="Microphone muted"
    icon="microphone-sensitivity-muted-symbolic"
fi

# The synchronous hint makes swaync replace the previous popup instead of stacking
notify-send -a "Microphone" -i "$icon" -t 1500 -u low \
    -h string:x-canonical-private-synchronous:mic-toggle \
    "$summary"
