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

echo "✅ Office setup script complete!"