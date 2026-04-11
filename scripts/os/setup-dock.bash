#!/bin/bash

# 1. Clear the Dock
defaults write com.apple.dock persistent-apps -array ""

# 2. Add System Settings
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# 3. Set static Dock size to smallest (16)
defaults write com.apple.dock tilesize -int 24

# 4. Enable Magnification
defaults write com.apple.dock magnification -bool true

# 5. Set Hover (Large) size to 'Medium' (roughly 48-64 range)
# The slider in Settings goes up to 128; 48 is a nice middle ground.
defaults write com.apple.dock largesize -int 64

# 6. Disable 'Recents' for a cleaner look
defaults write com.apple.dock show-recents -bool false

# 7. Restart Dock to apply everything
killall Dock

echo "Dock reset: Minimized size, medium magnification, Finder & Settings only."