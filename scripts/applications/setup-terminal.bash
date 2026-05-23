#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🚀 Starting Terminal Environment Setup..."

if [[ ! -d "/Applications/iTerm.app" ]]; then
    mac_setup_run "Homebrew cask: iTerm2" brew install --cask iterm2
else
    echo "✅ iTerm2 is already installed. Skipping..."
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    mac_setup_run "Oh My Zsh" \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh is already installed. Skipping..."
fi

mac_setup_finish "Terminal setup"
