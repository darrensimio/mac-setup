#!/usr/bin/env bash
# Configure macOS screenshot preferences (com.apple.screencapture).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths

echo "📸 Configuring screenshot preferences..."

SCREENSHOT_DIR="$HOME/screenshot"
mkdir -p "$SCREENSHOT_DIR"

defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
defaults write com.apple.screencapture disable-sound -bool true

# Applies immediately for screenshot UI / shortcuts.
killall SystemUIServer 2>/dev/null || true

location_ok=false
sound_ok=false
[[ "$(mac_setup_screenshot_location_status "$SCREENSHOT_DIR")" == "applied" ]] && location_ok=true
[[ "$(mac_setup_screenshot_disable_sound_status)" == "applied" ]] && sound_ok=true

if $location_ok; then
  echo "✅ Screenshot location: $SCREENSHOT_DIR"
  mac_setup_report "completed" "Screenshots: save location"
else
  current="$(defaults read com.apple.screencapture location 2>/dev/null || echo "<unset>")"
  echo "⚠️  Screenshot location still: $current" >&2
  mac_setup_report "skipped" "Screenshots: save location (verify manually)"
fi

if $sound_ok; then
  echo "✅ Screenshot sound: off"
  mac_setup_report "completed" "Screenshots: sound off"
else
  current="$(defaults read com.apple.screencapture disable-sound 2>/dev/null || echo "<unset>")"
  echo "⚠️  Screenshot sound still: $current" >&2
  mac_setup_report "skipped" "Screenshots: sound off (verify manually)"
fi

mac_setup_finish "Screenshot preferences"
