#!/bin/bash

echo "🗑️  Removing all active desktop widgets..."

# 1. Disable the 'Show Widgets on Desktop' preference
# This is the 'Master Switch' that clears them from the desktop view.
defaults write com.apple.WindowManager StandardHideWidgets -bool true

# 2. Specifically target the 'On Desktop' toggle in the Widgets section
defaults write com.apple.widgets show-on-desktop -bool false

# 3. Restart the background processes responsible for rendering widgets
# Chronod manages the widget data; WindowManager handles the desktop layer.
killall Chronod 2>/dev/null
killall WindowManager 2>/dev/null

echo "✅ Desktop widgets removed."