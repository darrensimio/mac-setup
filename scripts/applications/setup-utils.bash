#!/bin/bash

echo "⚙️  Setting up macOS Utilities..."

# Caffeinated
# Purpose: Prevents your Mac from sleeping or dimming.
# Docs: https://macenities.com/caffeinated
if [ ! -d "/Applications/Caffeinated.app" ]; then
    echo "Installing Caffeinated via Homebrew..."
    brew install --cask caffeinated
else
    echo "Caffeinated is already installed. Skipping..."
fi

# Hidden Bar
# Purpose: Menu bar organizer to hide inactive icons.
# Docs: https://github.com/dwarvesf/hidden
if [ ! -d "/Applications/Hidden Bar.app" ]; then
    echo "Installing Hidden Bar via Homebrew..."
    brew install --cask hiddenbar
else
    echo "Hidden Bar is already installed. Skipping..."
fi

# DisplayLink Manager
# Purpose: Driver software for docking stations and external monitors.
# Docs: https://www.synaptics.com/products/displaylink-graphics
if [ ! -d "/Applications/DisplayLink Manager.app" ]; then
    echo "Installing DisplayLink Manager via Homebrew..."
    brew install --cask displaylink
else
    echo "DisplayLink Manager is already installed. Skipping..."
fi

# mas-cli
# mas-cli (Mac App Store CLI) is a command-line interface for the Mac App Store.
# It allows us to script the installation of official apps using their unique Store IDs.
# Docs: https://github.com/mas-cli/mas
if ! command -v mas &> /dev/null; then
    echo "mas-cli not found. Installing via Homebrew..."
    brew install mas
else
    echo "mas-cli is already installed. Skipping..."
fi

# Stats
# Purpose: Open-source system monitor for the menu bar (CPU, GPU, RAM, Network).
# Docs: https://github.com/exelban/stats
if ! command -v stats &> /dev/null && [ ! -d "/Applications/Stats.app" ]; then
    echo "Installing Stats via Homebrew..."
    brew install --cask stats
else
    echo "✅ Stats is already installed. Skipping..."
fi

# Automate Stats config
if [ -f "./configs/eu.exelban.Stats.plist" ]; then
    echo "⚙️  Restoring Stats preferences..."
    cp "./configs/eu.exelban.Stats.plist" "$HOME/Library/Preferences/"
    
    # Force macOS to reload the preferences from disk
    defaults read eu.exelban.Stats > /dev/null
    echo "✅ Stats preferences restored."
else
    echo "ℹ️  No Stats preference file found in ./prefs/. Skipping restore."
fi

echo "✅ Utilities setup complete!"