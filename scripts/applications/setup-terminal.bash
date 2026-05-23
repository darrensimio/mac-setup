#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🚀 Starting Terminal Environment Setup..."

if [[ ! -d "/Applications/iTerm.app" ]]; then
    local brew_out brew_status
    brew_out=$(brew install --cask iterm2 2>&1) && brew_status=0 || brew_status=$?
    if [[ $brew_status -eq 0 ]]; then
        mac_setup_report "installed" "iTerm2"
    else
        echo "$brew_out" >&2
        mac_setup_record_failure "Homebrew cask: iTerm2"
        mac_setup_report_failed "iTerm2" "$brew_out" "brew install --cask iterm2"
    fi
else
    echo "✅ iTerm2 is already installed. Skipping..."
    mac_setup_report "already" "iTerm2"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    local omz_out omz_status
    omz_out=$(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1) && omz_status=0 || omz_status=$?
    if [[ $omz_status -eq 0 ]]; then
        mac_setup_report "installed" "Oh My Zsh"
    else
        echo "$omz_out" >&2
        mac_setup_record_failure "Oh My Zsh"
        mac_setup_report_failed "Oh My Zsh" "$omz_out" "oh-my-zsh install"
    fi
else
    echo "✅ Oh My Zsh is already installed. Skipping..."
    mac_setup_report "already" "Oh My Zsh"
fi

mac_setup_finish "Terminal setup"
