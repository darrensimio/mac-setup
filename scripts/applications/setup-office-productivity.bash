#!/bin/bash

echo "💼 Setting up Office Productivity Apps via App Store..."

# Function to install from App Store using mas
install_mas_app() {
    # $1 is the App ID, $2 is the Name
    if ! mas list | grep -q "$1"; then
        echo "Installing $2..."
        mas install "$1"
    else
        echo "$2 is already installed. Skipping..."
    fi
}

# --- Microsoft Apps ---
# Microsoft Word
install_mas_app "462054704" "Microsoft Word"

# Microsoft Excel
install_mas_app "462058435" "Microsoft Excel"

# Microsoft PowerPoint
install_mas_app "462062816" "Microsoft PowerPoint"

# Windows App (Remote Desktop)
install_mas_app "1295203466" "Windows App"

# --- Apple Apps ---
# Apple Pages
install_mas_app "409201541" "Pages"

# Apple Numbers
install_mas_app "409203825" "Numbers"

# Apple Keynote
install_mas_app "409183694" "Keynote"

# --- Proton Suite ---
# Proton Mail
if [ ! -d "/Applications/Proton Mail.app" ]; then
    echo "Installing Proton Mail via Homebrew..."
    brew install --cask proton-mail
else
    echo "✅ Proton Mail is already installed. Skipping..."
fi

# Proton Pass
if [ ! -d "/Applications/Proton Pass.app" ]; then
    echo "Installing Proton Pass via Homebrew..."
    brew install --cask proton-pass
else
    echo "✅ Proton Pass is already installed. Skipping..."
fi

# Proton VPN
if [ ! -d "/Applications/Proton VPN.app" ]; then
    echo "Installing Proton VPN via Homebrew..."
    brew install --cask protonvpn
else
    echo "✅ Proton VPN is already installed. Skipping..."
fi


# 1Password8
install_mas_app "1333542190" "1Password"


# Notion
# Purpose: All-in-one workspace for notes, tasks, and project docs.
# Docs: https://www.notion.so/desktop
if [ ! -d "/Applications/Notion.app" ]; then
    echo "Installing Notion via Homebrew..."
    brew install --cask notion
else
    echo "✅ Notion is already installed. Skipping..."
fi


echo "✅ Office setup script complete!"