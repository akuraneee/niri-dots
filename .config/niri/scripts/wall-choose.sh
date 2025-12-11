#!/bin/sh
# Select wallpaper file
FILE=$(zenity --file-selection --title="Select wallpaper" --file-filter="Images and Videos | *.jpg *.png *.gif *.mp4 *.webm *.mkv")

if [ -n "$FILE" ]; then
    # Create ~/Pictures/Wallpapers folder if it doesn't exist
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    if [ ! -d "$WALLPAPER_DIR" ]; then
        mkdir -p "$WALLPAPER_DIR"
        echo "Folder created: $WALLPAPER_DIR"
    fi
    
    # Get filename and extension
    FILENAME=$(basename "$FILE")
    EXTENSION="${FILENAME##*.}"
    DEST_FILE="$WALLPAPER_DIR/$FILENAME"
    
    # Copy file to wallpapers folder
    if [ "$FILE" != "$DEST_FILE" ]; then
        cp "$FILE" "$DEST_FILE"
        echo "Wallpaper copied to: $DEST_FILE"
    else
        echo "File is already in wallpapers folder"
    fi
    
    # Create state file directory
    STATE_DIR="$HOME/.config/niri/scripts"
    mkdir -p "$STATE_DIR"
    STATE_FILE="$STATE_DIR/wall-instance"
    
    # Check file type and use appropriate tool
    case "$EXTENSION" in
        mp4|webm|mkv|avi|mov)
            # Use mpvpaper for videos
            echo "Video detected, using mpvpaper..."
            # Stop swww if running
            if pgrep -x "swww-daemon" >/dev/null; then
                pkill swww-daemon
            fi
            # Stop old mpvpaper if running
            pkill mpvpaper
            sleep 0.3
            # Start mpvpaper
            mpvpaper '*' "$FILE" --mpv-options="--loop --no-audio --hwdec=auto" &
            #mpvpaper '*' "$FILE" --loop --mpv-options="--no-audio --hwdec=auto" &
            # Save state to file
            echo "mpvpaper|$FILE" > "$STATE_FILE"
            echo "Video wallpaper set: $FILE"
            ;;
        jpg|jpeg|png|gif)
            # Use swww for images
            echo "Image detected, using swww..."
            # Stop mpvpaper if running
            pkill mpvpaper
            swww-daemon
            sleep 0.3
            # Start swww
            if pgrep -x "swww-daemon" >/dev/null; then
                swww init
                sleep 0.5
                swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
            else
                swww init
                sleep 0.5
                swww img "$FILE" --transition-fps 240 --transition-type grow --transition-duration 0.5
            fi
            # Save state to file
            echo "swww|$FILE" > "$STATE_FILE"
            echo "Wallpaper set: $FILE"
            ;;
        *)
            echo "Unsupported file format: $EXTENSION"
            zenity --error --text="Unsupported file format"
            ;;
    esac
else
    echo "No file selected"
fi
