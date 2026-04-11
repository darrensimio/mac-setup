#!/bin/bash

echo "🛠️  Setting up Developer Tools..."

# Visual Studio Code
# Purpose: Core code editor. Includes symlinking the 'code' binary to your PATH.
# Docs: https://code.visualstudio.com/docs/setup/mac
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "Installing Visual Studio Code via Homebrew..."
    brew install --cask visual-studio-code
    
    # Pathing VS Code: Create a symlink so 'code' works in terminal
    echo "Pathing VS Code binary..."
    sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
else
    echo "Visual Studio Code is already installed. Skipping..."
fi

# Bruno
# Purpose: Open-source IDE for exploring and testing APIs (Postman alternative).
# Docs: https://docs.usebruno.com/
if [ ! -d "/Applications/Bruno.app" ]; then
    echo "Installing Bruno via Homebrew..."
    brew install --cask bruno
else
    echo "Bruno is already installed. Skipping..."
fi

# tig: Text-mode interface for git
# Purpose: A visual browser for git logs and staging changes.
# Docs: https://jonas.github.io/tig/doc/tig.1.html
if ! command -v tig &> /dev/null; then
    echo "Installing tig via Homebrew..."
    brew install tig
else
    echo "tig is already installed. Skipping..."
fi

# gh: GitHub's official command line tool
# Purpose: Manage PRs, issues, and repos from the terminal.
# Docs: https://cli.github.com/manual/
if ! command -v gh &> /dev/null; then
    echo "Installing gh via Homebrew..."
    brew install gh
else
    echo "gh is already installed. Skipping..."
fi

# htop: Interactive process viewer
# Purpose: A sophisticated version of 'top' for monitoring CPU/RAM.
# Docs: https://htop.dev/
if ! command -v htop &> /dev/null; then
    echo "Installing htop via Homebrew..."
    brew install htop
else
    echo "htop is already installed. Skipping..."
fi

# curlie: Power of curl with the ease of httpie
# Purpose: Simple syntax and pretty-printed output for API requests.
# Docs: https://curlie.io/
if ! command -v curlie &> /dev/null; then
    echo "Installing curlie via Homebrew..."
    brew install curlie
else
    echo "curlie is already installed. Skipping..."
fi

echo "✅ Dev tools setup complete!"