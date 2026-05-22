#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew

echo "🚀 Starting Terminal Environment Setup..."

# iTerm2 via Homebrew
if [[ ! -d "/Applications/iTerm.app" ]]; then
    echo "Installing iTerm2..."
    brew install --cask iterm2
else
    echo "✅ iTerm2 is already installed. Skipping..."
fi

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh is already installed. Skipping..."
fi

echo "✅ Terminal setup complete!"
