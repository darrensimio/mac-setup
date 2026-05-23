#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🚀 Starting Terminal Environment Setup..."

if [[ ! -d "/Applications/iTerm.app" ]]; then
    if brew install --cask iterm2; then
        mac_setup_report "installed" "iTerm2"
    else
        mac_setup_record_failure "Homebrew cask: iTerm2"
        mac_setup_report "failed" "iTerm2"
    fi
else
    echo "✅ iTerm2 is already installed. Skipping..."
    mac_setup_report "already" "iTerm2"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        mac_setup_report "installed" "Oh My Zsh"
    else
        mac_setup_record_failure "Oh My Zsh"
        mac_setup_report "failed" "Oh My Zsh"
    fi
else
    echo "✅ Oh My Zsh is already installed. Skipping..."
    mac_setup_report "already" "Oh My Zsh"
fi

mac_setup_finish "Terminal setup"
