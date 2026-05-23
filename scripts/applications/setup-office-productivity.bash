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
install_mas_app "1113153706" "Microsoft Teams"

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
    mac_setup_run "Homebrew cask: Zoom" brew install --cask zoom
else
    echo "✅ Zoom is already installed. Skipping..."
fi

install_mas_app "803453959" "Slack"
install_mas_app "310633997" "WhatsApp"
install_mas_app "747648890" "Telegram"

mac_setup_finish "Office productivity setup"
