#!/bin/sh

# Выбираем файл обоев
FILE=$(zenity --file-selection --title="Выберите обои" --file-filter="*.jpg *.png")

if [ -n "$FILE" ]; then
    # Создаём папку ~/Pictures/Wallpapers если её нет
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    if [ ! -d "$WALLPAPER_DIR" ]; then
        mkdir -p "$WALLPAPER_DIR"
        echo "Создана папка: $WALLPAPER_DIR"
    fi
    
    # Получаем имя файла из полного пути
    FILENAME=$(basename "$FILE")
    DEST_FILE="$WALLPAPER_DIR/$FILENAME"
    
    # Копируем файл в папку с обоями
    if [ "$FILE" != "$DEST_FILE" ]; then
        cp "$FILE" "$DEST_FILE"
        echo "Обои скопированы в: $DEST_FILE"
    else
        echo "Файл уже находится в папке с обоями"
    fi
    
    # Устанавливаем обои через swww
    if pgrep -x "swww-daemon" >/dev/null; then
        swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
    else
        swww init
        swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
    fi
    
    echo "Обои установлены: $FILE"
else
    echo "Файл не выбран"
fi
