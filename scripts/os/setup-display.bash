#!/bin/bash

# 1. Check if displayplacer is already installed
if ! command -v displayplacer &> /dev/null; then
    echo "displayplacer not found. Installing via Homebrew..."
    brew install displayplacer
else
    echo "displayplacer is already installed. Skipping installation."
fi

# 2. Configure the Dock (Finder + System Settings Only)
echo "Configuring Dock icons..."
defaults write com.apple.dock persistent-apps -array ""
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# 3. Set Dock Aesthetics
echo "Setting Dock size and magnification..."
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 48
defaults write com.apple.dock show-recents -bool false

# 4. Restart Dock to apply changes
killall Dock

# 5. Set Display to 'More Space'
echo "Applying display scaling..."
# On most MacBooks, 1920x1200 is the 'More Space' HiDPI toggle.
displayplacer "res:1920x1200 scaling:on origin:(0,0) degree:0"

echo "✅ Setup Complete!"