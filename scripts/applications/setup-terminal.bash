#!/bin/bash

echo "🚀 Starting Terminal Environment Setup..."

# 1. Install iTerm2 via Homebrew
if ! command -v iterm2 &> /dev/null && [ ! -d "/Applications/iTerm.app" ]; then
    echo "Installing iTerm2..."
    brew install --cask iterm2
else
    echo "iTerm2 is already installed. Skipping..."
fi

# 2. Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed. Skipping..."
fi

echo "✅ Terminal setup complete!"