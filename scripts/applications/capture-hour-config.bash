#!/usr/bin/env bash
# Copy Hour - World Clock preferences from this Mac into scripts/applications/configs/.
# Requires Terminal (or iTerm) Full Disk Access to read sandboxed app data.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths

HOUR_CONTAINER_PREFS="$HOME/Library/Containers/com.fabriceleyne.hourlite/Data/Library/Preferences"
HOUR_GROUP_PREFS="$HOME/Library/Group Containers/3EYN7PPTPF.com.fabriceleyne.hourlite/Library/Preferences"
DEST_CONTAINER="$CONFIGS_DIR/hour-world-clock/container"
DEST_GROUP="$CONFIGS_DIR/hour-world-clock/group"

echo "Capturing Hour - World Clock preferences..."

osascript -e 'tell application "Hour" to quit' 2>/dev/null || true
sleep 1

mkdir -p "$DEST_CONTAINER" "$DEST_GROUP"
rm -f "$DEST_CONTAINER"/*.plist "$DEST_GROUP"/*.plist 2>/dev/null || true

copied=0
if [[ -d "$HOUR_CONTAINER_PREFS" ]]; then
    shopt -s nullglob
    for f in "$HOUR_CONTAINER_PREFS"/*.plist; do
        cp -f "$f" "$DEST_CONTAINER/"
        copied=$((copied + 1))
        echo "  container: $(basename "$f")"
    done
    shopt -u nullglob
fi

if [[ -d "$HOUR_GROUP_PREFS" ]]; then
    shopt -s nullglob
    for f in "$HOUR_GROUP_PREFS"/*.plist; do
        cp -f "$f" "$DEST_GROUP/"
        copied=$((copied + 1))
        echo "  group: $(basename "$f")"
    done
    shopt -u nullglob
fi

if (( copied == 0 )); then
    echo "⚠️  No Hour preference plists found." >&2
    echo "    Quit Hour, then grant Terminal Full Disk Access:" >&2
    echo "    System Settings → Privacy & Security → Full Disk Access" >&2
    echo "    Re-run: bash scripts/applications/capture-hour-config.bash" >&2
    exit 1
fi

echo "✅ Captured $copied plist(s) under scripts/applications/configs/hour-world-clock/"
echo "   Commit container/*.plist and group/*.plist to git (see configs/README.md)."
