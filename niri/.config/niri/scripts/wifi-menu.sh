#!/usr/bin/env bash
# Wi-Fi menu in fuzzel: pick a network to connect to, toggle the radio,
# disconnect or rescan. Opened from the "Wi-Fi" launcher entry and by
# clicking the network module in waybar.

notify() {
    # The synchronous hint makes swaync replace the previous popup instead of stacking
    notify-send -a "Wi-Fi" -i network-wireless-symbolic -t 3000 -u low \
        -h string:x-canonical-private-synchronous:wifi "$@"
}

menu() {  # menu PROMPT < lines  →  index of the picked line
    fuzzel --dmenu --index --prompt "$1" --width 45 --lines 12
}

if [[ $(nmcli radio wifi) != enabled ]]; then
    pick=$(printf '󰖩  Turn Wi-Fi on\n' | menu "Wi-Fi off  ")
    [[ $pick == 0 ]] && nmcli radio wifi on && notify "Wi-Fi on"
    exit
fi

rescan=auto
[[ $1 == --rescan ]] && rescan=yes

device=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2 == "wifi" { print $1; exit }')
current=$(nmcli -g GENERAL.CONNECTION device show "$device" 2>/dev/null)

# Saved Wi-Fi profiles, matched by their real SSID: profile names may differ
# ("MyWifi 1") or carry stray whitespace, so never assume name == SSID
declare -A saved_uuid
while IFS=: read -r uuid type; do
    [[ $type == 802-11-wireless ]] || continue
    saved_uuid[$(nmcli -g 802-11-wireless.ssid connection show uuid "$uuid")]=$uuid
done < <(nmcli -t -f UUID,TYPE connection show)
is_saved() { [[ -n ${saved_uuid[$1]} ]]; }

# SSID goes last so colons inside it survive the split; drop hidden networks
# and duplicate access points of the same network (the list is sorted by signal)
ssids=() lines=()
icons=(󰤯 󰤟 󰤢 󰤥 󰤨)
while IFS=: read -r in_use signal security ssid; do
    [[ -z $ssid ]] && continue
    printf '%s\n' "${ssids[@]}" | grep -qxF -- "$ssid" && continue
    icon=${icons[signal * 4 / 100]}
    lock=""; [[ -n $security && $security != -- ]] && lock="  󰌾"
    mark=""; [[ $in_use == '*' ]] && mark="  "$'\uf00c'
    ssids+=("$ssid")
    lines+=("$icon  $ssid$lock$mark  ${signal}%")
done < <(nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID device wifi list \
    --rescan "$rescan" | sort -t: -k2,2nr)

actions=("󰑐  Rescan" "󰖪  Turn Wi-Fi off")
[[ -n $current ]] && actions+=("󰅛  Disconnect")

pick=$(printf '%s\n' "${actions[@]}" "${lines[@]}" | menu "Wi-Fi${current:+: $current}  ")
[[ -z $pick ]] && exit

case "${actions[pick]}" in
    *Rescan)     exec "$0" --rescan ;;
    *"Wi-Fi off") nmcli radio wifi off && notify "Wi-Fi off"; exit ;;
    *Disconnect) nmcli connection down id "$current" >/dev/null && notify "Disconnected from $current"; exit ;;
esac

ssid=${ssids[pick - ${#actions[@]}]}
line=${lines[pick - ${#actions[@]}]}

if is_saved "$ssid"; then
    uuid=${saved_uuid[$ssid]}
    # Profiles made under another interface name (wlp2s0 vs wlan0, other
    # machine) are refused as incompatible; rebind them to this device
    bound=$(nmcli -g connection.interface-name connection show uuid "$uuid")
    [[ -n $bound && $bound != "$device" ]] &&
        nmcli connection modify uuid "$uuid" connection.interface-name "$device"
    out=$(nmcli connection up uuid "$uuid" 2>&1)
elif [[ $line == *󰌾* ]]; then
    password=$(fuzzel --dmenu --password --prompt "Password for $ssid  " --lines 0 --width 45 </dev/null)
    [[ -z $password ]] && exit
    out=$(nmcli device wifi connect "$ssid" password "$password" 2>&1)
else
    out=$(nmcli device wifi connect "$ssid" 2>&1)
fi
status=$?

if (( status == 0 )); then
    notify "Connected to $ssid"
else
    # Don't keep a freshly created profile with a wrong password
    is_saved "$ssid" || nmcli connection delete id "$ssid" >/dev/null 2>&1
    notify "Couldn't connect to $ssid" "${out#Error: }"
fi
