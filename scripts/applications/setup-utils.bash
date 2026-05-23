#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "⚙️  Setting up macOS Utilities..."

ensure_mas_installed

install_mas_app "419330170" "Moom Classic"
if [[ -d "/Applications/Moom Classic.app" ]]; then
    open -a "Moom Classic" 2>/dev/null || true
fi

if install_cask_if_missing "Spotify.app" spotify; then
    open -a Spotify 2>/dev/null || true
fi

install_cask_if_missing "Caffeinated.app" caffeinated

if install_cask_if_missing "Hidden Bar.app" hiddenbar; then
    open -a "Hidden Bar" 2>/dev/null || true
fi

install_cask_if_missing "DisplayLink Manager.app" displaylink

if ! command -v stats &>/dev/null && [[ ! -d "/Applications/Stats.app" ]]; then
    mac_setup_run "Homebrew cask: Stats" brew install --cask stats
else
    echo "✅ Stats is already installed. Skipping..."
fi

restore_plist_if_present "eu.exelban.Stats.plist"

if install_cask_if_missing "Jabra Direct.app" jabra-direct; then
    open -a "Jabra Direct" 2>/dev/null || true
fi

if install_cask_if_missing "Logi Options+.app" logi-options+; then
    open -a "Logi Options+" 2>/dev/null || true
fi

mac_setup_finish "Utilities setup"
