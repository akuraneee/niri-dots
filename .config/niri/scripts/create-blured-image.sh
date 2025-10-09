#!/bin/bash

# Set PATH explicitly
export PATH="/usr/local/bin:/usr/bin:/bin"

WALLPAPER_FILE="$HOME/.cache/current_wallpaper"
BLUR_DIR="$HOME/Pictures/Wallpapers/tmp"
BLUR_FILE="$BLUR_DIR/blured_current_wallpaper.png"

# Create tmp directory if it doesn't exist
mkdir -p "$BLUR_DIR"

# Check if wallpaper path exists
if [ -f "$WALLPAPER_FILE" ]; then
    CURRENT_WALL=$(cat "$WALLPAPER_FILE")
    
    if [ -f "$CURRENT_WALL" ]; then
        echo "Generating blurred lockscreen from: $CURRENT_WALL"
        /usr/bin/magick "$CURRENT_WALL" -blur 0x8 "$BLUR_FILE"
        
        if [ -f "$BLUR_FILE" ]; then
            echo "Lockscreen blur created successfully at: $BLUR_FILE"
        else
            echo "Error: Failed to create blur"
        fi
    else
        echo "Error: Wallpaper file not found: $CURRENT_WALL"
    fi
else
    echo "Error: No wallpaper path saved"
fi
