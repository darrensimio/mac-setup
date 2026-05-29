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

# Optional local preference restore (gitignored by default; see scripts/applications/configs/README.md)
restore_plist_if_present "moom-classic/com.manytricks.Moom.plist"

if install_cask_if_missing "Spotify.app" spotify; then
    open -a Spotify 2>/dev/null || true
fi

# Caffeinated — Homebrew cask removed; install from Mac App Store (paid app)
install_mas_app "1362171212" "Caffeinated"

if install_cask_if_missing "Hidden Bar.app" hiddenbar; then
    open -a "Hidden Bar" 2>/dev/null || true
fi

restore_plist_if_present "hidden-bar/com.dwarvesv.minimalbar.plist"

install_cask_if_missing "DisplayLink Manager.app" displaylink

if ! command -v stats &>/dev/null && [[ ! -d "/Applications/Stats.app" ]]; then
    local brew_out brew_status
    brew_out=$(brew install --cask stats 2>&1) && brew_status=0 || brew_status=$?
    if [[ $brew_status -eq 0 ]]; then
        mac_setup_report "installed" "Stats"
    else
        echo "$brew_out" >&2
        mac_setup_record_failure "Homebrew cask: Stats"
        mac_setup_report_failed "Stats" "$brew_out" "brew install --cask stats"
    fi
else
    echo "✅ Stats is already installed. Skipping..."
    mac_setup_report "already" "Stats"
fi

restore_plist_if_present "eu.exelban.Stats.plist"

mac_setup_finish "Utilities setup"
