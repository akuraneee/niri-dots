#!/bin/sh
# Restore wallpaper on system startup

STATE_FILE="$HOME/.config/niri/scripts/wall-instance"

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    echo "No wallpaper state file found"
    exit 0
fi

# Read state file
STATE=$(cat "$STATE_FILE")
TOOL=$(echo "$STATE" | cut -d'|' -f1)
WALLPAPER=$(echo "$STATE" | cut -d'|' -f2)

# Check if wallpaper file exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Wallpaper file not found: $WALLPAPER"
    exit 1
fi

echo "Restoring wallpaper: $WALLPAPER using $TOOL"

# Restore wallpaper based on tool
case "$TOOL" in
    mpvpaper)
        # Wait a bit for system to fully start
        sleep 2
        mpvpaper '*' "$WALLPAPER"  --mpv-options="--loop --no-audio --hwdec=auto" &
        echo "Video wallpaper restored"
        ;;
    swww)
        # Start swww daemon
        swww-daemon
        sleep 1
        swww img "$WALLPAPER" --transition-fps 240 --transition-type grow --transition-duration 0.5
        echo "Image wallpaper restored"
        ;;
    *)
        echo "Unknown tool: $TOOL"
        exit 1
        ;;
esac
