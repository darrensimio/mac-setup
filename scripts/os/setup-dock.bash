#!/bin/bash

# Clear the Dock
# Removes all default apps to start with a blank slate
defaults write com.apple.dock persistent-apps -array ""

# Add Web Browsers
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Safari
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Google Chrome
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Edge.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Microsoft Edge

# Add Microsoft Office Suite
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Word.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Excel.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft PowerPoint.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add System Settings
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Set static Dock size to smallest (24)
defaults write com.apple.dock tilesize -int 24

# Enable Magnification
defaults write com.apple.dock magnification -bool true

# Set Hover (Large) size to 64
defaults write com.apple.dock largesize -int 64

# Disable 'Recents' for a cleaner look
defaults write com.apple.dock show-recents -bool false

# Restart Dock to apply everything
killall Dock

echo "Dock reset complete: Finder, System Settings, and MS Office Suite only."