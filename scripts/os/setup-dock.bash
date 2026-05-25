#!/bin/bash

# Clear the Dock
# Removes all default apps to start with a blank slate
defaults write com.apple.dock persistent-apps -array ""

# Add Web Browsers
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Safari
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Google Chrome
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Edge.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Microsoft Edge

# Add Spotify
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Spotify

# Add Email Clients
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Mail
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Proton Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Proton Mail

# Add Messaging Apps
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Messages.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Messages
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/WhatsApp.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # WhatsApp
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Telegram.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Telegram

# Add Notion AI
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Notion.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Notion

# Add Microsoft Office Suite
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Word.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Excel.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft PowerPoint.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add App Store
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/App Store.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # App Store

# Add System Settings
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add Password Managers
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Proton Pass.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # Proton Pass
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/1Password.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" # 1Password

# Add Windows App
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Windows App.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add iTerm
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add VS Code
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Set static Dock size to smallest (24)
defaults write com.apple.dock tilesize -int 24

# Enable Magnification
defaults write com.apple.dock magnification -bool true

# Set Hover (Large) size to 96
defaults write com.apple.dock largesize -int 96

# Disable 'Recents' for a cleaner look
defaults write com.apple.dock show-recents -bool false

# Configure Hot Corners
echo "⚙️  Configuring Hot Corner: Bottom-Left to Lock Screen..."

# Set screen to lock immediately after sleep or screen saver begins
echo "🔐 Setting lock screen timeout to: Immediately..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Set the Action
defaults write com.apple.dock wvous-bl-corner -int 13
# Set the Modifier (0 = None)
defaults write com.apple.dock wvous-bl-modifier -int 0

# Set the Action
defaults write com.apple.dock wvous-br-corner -int 13
# Set the Modifier (0 = None)
defaults write com.apple.dock wvous-br-modifier -int 0

# Restart Dock to apply everything
killall cfprefsd
killall Dock

echo "Dock reset complete: Finder, System Settings, and MS Office Suite only."