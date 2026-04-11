#!/bin/bash

# 1. Clear everything out first
defaults write com.apple.dock persistent-apps -array ""

# 2. Explicitly add System Settings
# Note: Finder is handled by the OS, so we only need to add the Settings app path
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# 3. Disable the 'Recents' section to ensure ONLY your two icons show
defaults write com.apple.dock show-recents -bool false

# 4. Restart the Dock to apply
killall Dock

echo "Done! Your Dock now only contains Finder and System Settings."