
#!/bin/sh

FILE=$(zenity --file-selection --title="Выберите обои" --file-filter="*.jpg *.png")

if [ -n "$FILE" ]; then
    if pgrep -x "swww-daemon" >/dev/null; then
        swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
    else
        swww init
        swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
    fi
fi
