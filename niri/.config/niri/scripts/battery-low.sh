#!/usr/bin/env bash
# Run once by waybar's battery module when it drops into the "critical" state
# (below 20% while discharging). Offers to switch to the power-saver profile.

[[ $(powerprofilesctl get) == power-saver ]] && exit 0

capacity=$(</sys/class/power_supply/BAT0/capacity)

# -A makes notify-send wait for a click; detach so waybar isn't kept waiting
(
    action=$(notify-send -a "Battery" -i battery-caution-symbolic -u critical \
        -A saver="Enable power saver" \
        "Battery low: $capacity%" "Switch to the power-saver profile?")
    [[ $action == saver ]] && powerprofilesctl set power-saver
) &
