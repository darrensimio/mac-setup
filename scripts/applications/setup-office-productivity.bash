#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew mas || exit 1

echo "💼 Setting up Office Productivity Apps..."

install_mas_app "462054704" "Microsoft Word"
install_mas_app "462058435" "Microsoft Excel"
install_mas_app "462062816" "Microsoft PowerPoint"
install_mas_app "1295203466" "Windows App"

# Teams: App Store ID 1113153706 is iOS/iPad only — desktop Teams is via Homebrew
install_cask_if_missing "Microsoft Teams.app" microsoft-teams

install_cask_if_missing "Microsoft Edge.app" microsoft-edge

install_mas_app "409201541" "Pages"
install_mas_app "409203825" "Numbers"
install_mas_app "409183694" "Keynote"

install_cask_if_missing "Proton Mail.app" proton-mail
install_cask_if_missing "Proton Pass.app" proton-pass
install_cask_if_missing "Proton VPN.app" protonvpn
install_cask_if_missing "1Password.app" 1password
install_cask_if_missing "Notion.app" notion
install_cask_if_missing "Google Chrome.app" google-chrome

if [[ ! -d "/Applications/zoom.us.app" ]]; then
    if brew install --cask zoom; then
        mac_setup_report "installed" "Zoom"
    else
        mac_setup_record_failure "Homebrew cask: Zoom"
        mac_setup_report "failed" "Zoom"
    fi
else
    echo "✅ Zoom is already installed. Skipping..."
    mac_setup_report "already" "Zoom"
fi

install_mas_app "803453959" "Slack"
install_mas_app "310633997" "WhatsApp"
install_mas_app "747648890" "Telegram"

mac_setup_finish "Office productivity setup"
