#!/bin/bash

# Set PATH explicitly
export PATH="/usr/local/bin:/usr/bin:/bin"

# Redirect output to log for debugging
LOG_FILE="/tmp/lock-debug.log"
exec > "$LOG_FILE" 2>&1

echo "=== Lock script started at $(date) ==="

BLUR_DIR="$HOME/Pictures/Wallpapers/tmp"
BLUR_FILE="$BLUR_DIR/blured_current_wallpaper.png"
WALLPAPER_TRACK_FILE="$BLUR_DIR/current-wallpaper-blured"

# Create tmp directory if it doesn't exist
mkdir -p "$BLUR_DIR"

# Get current wallpaper from swww
CURRENT_WALL=$(/usr/bin/swww query 2>/dev/null | head -n1 | grep -oP 'image: \K.*' | xargs)

if [ -z "$CURRENT_WALL" ] || [ ! -f "$CURRENT_WALL" ]; then
    echo "Error: Could not get current wallpaper from swww"
    echo "CURRENT_WALL value: '$CURRENT_WALL'"
    /usr/bin/gtklock
    exit 0
fi

echo "Current wallpaper: $CURRENT_WALL"

# Check if we need to regenerate blur
NEED_REGENERATE=false

if [ ! -f "$BLUR_FILE" ]; then
    echo "Blur file doesn't exist, need to generate"
    NEED_REGENERATE=true
elif [ ! -f "$WALLPAPER_TRACK_FILE" ]; then
    echo "Track file doesn't exist, need to generate"
    NEED_REGENERATE=true
else
    TRACKED_WALL=$(cat "$WALLPAPER_TRACK_FILE")
    if [ "$CURRENT_WALL" != "$TRACKED_WALL" ]; then
        echo "Wallpaper changed, need to regenerate"
        echo "Old: $TRACKED_WALL"
        echo "New: $CURRENT_WALL"
        NEED_REGENERATE=true
    fi
fi

# Regenerate blur if needed
if [ "$NEED_REGENERATE" = true ]; then
    echo "Generating new blurred lockscreen..."
    /usr/bin/magick "$CURRENT_WALL" -blur 0x8 "$BLUR_FILE" 2>&1
    
    if [ -f "$BLUR_FILE" ]; then
        echo "Blur created successfully"
        echo "$CURRENT_WALL" > "$WALLPAPER_TRACK_FILE"
        echo "Tracked wallpaper updated"
    else
        echo "Error: Failed to create blur"
        /usr/bin/gtklock
        exit 0
    fi
else
    echo "Using existing blur"
fi

echo "Launching gtklock..."

# Launch gtklock with blurred wallpaper
/usr/bin/gtklock -b "$BLUR_FILE"

echo "=== Lock script finished at $(date) ==="
