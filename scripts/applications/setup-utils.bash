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

echo "✅ Utilities setup complete!"