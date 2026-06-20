#!/usr/bin/env bash
# Menu bar / Control Center preferences.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths

echo "📶 Configuring menu bar..."

# Control Center → Battery → Show Percentage (per-machine setting)
# https://support.apple.com/guide/mac-help/mchlp2995/mac
if defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true; then
    echo "✅ Battery percentage enabled in menu bar"
    mac_setup_report "completed" "Menu bar: battery percentage"
else
    mac_setup_record_failure "Menu bar: battery percentage"
    mac_setup_report_failed "Menu bar: battery percentage" \
        "defaults -currentHost write failed" \
        "defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true"
fi

# Ensure battery item is visible in the menu bar (not hidden in Control Center only)
defaults -currentHost write com.apple.controlcenter Battery -int 18 2>/dev/null || true

killall ControlCenter 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

mac_setup_finish "Menu bar setup"
