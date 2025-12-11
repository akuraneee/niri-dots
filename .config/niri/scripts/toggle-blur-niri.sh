
#!/usr/bin/env bash

CONFIG="$HOME/.config/niri/config.kdl"
TMP_FILE="$(mktemp)"

awk '
/blur[[:space:]]*\{/ { in_blur=1 }  # нашли blur { где угодно в строке

in_blur {
    # Тогглим on ↔ off
    if ($0 ~ /\bon\b/) gsub(/\bon\b/, "off")
    else if ($0 ~ /\boff\b/) gsub(/\boff\b/, "on")
}

/\}/ && in_blur { in_blur=0 }       # вышли из блока blur
{ print }
' "$CONFIG" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG"

# Опционально — перезапустить niri, чтобы применились изменения:
# pkill -HUP niri

echo "✅ Тоггл blur завершён: on ↔ off внутри всех blur{}"
