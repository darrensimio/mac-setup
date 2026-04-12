#!/bin/bash

echo "⚙️  Setting up macOS Utilities..."

# Moom Classic
# Purpose: Window management utility for moving and zooming windows.
# ID: 419330170
install_mas_app "419330170" "Moom Classic"
if [ -d "/Applications/Moom Classic.app" ]; then
    echo "🚀 Launching Moom Classic..."
    open -a "Moom Classic"
fi

# Spotify
# Purpose: Music streaming service.
# Docs: https://www.spotify.com/download/mac/
if [ ! -d "/Applications/Spotify.app" ]; then
    echo "Installing Spotify via Homebrew..."
    brew install --cask spotify
    
    echo "🚀 Launching Spotify..."
else
    echo "✅ Spotify is already installed. Skipping..."
fi

# Alfred 5
# Purpose: Productivity app for launching apps, searching the web, and automation.
# Docs: https://www.alfredapp.com/help/
if [ ! -d "/Applications/Alfred 5.app" ]; then
    echo "Installing Alfred 5 via Homebrew..."
    brew install --cask alfred
    
    echo "🚀 Launching Alfred 5..."
    open -a "Alfred 5"
else
    echo "✅ Alfred 5 is already installed. Skipping..."
fi

if [ -d "$ALFRED_PREFS" ]; then
    echo "⚙️  Restoring Alfred 5 preferences..."

    ALFRED_DIR="$HOME/Library/Application Support/Alfred"
    ALFRED_PREFS="./configs/Alfred.alfredpreferences"
    
    # Ensure the Alfred directory exists
    mkdir -p "$ALFRED_DIR"
    
    # Copy the preferences bundle
    cp -R "$ALFRED_PREFS" "$ALFRED_DIR/"
    
    echo "✅ Alfred 5 preferences restored."
else
    echo "ℹ️  No Alfred preferences found in ./configs/. Skipping restore."
fi

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

    echo "🚀 Activating Hidden Bar..."
    open -a "Hidden Bar"
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