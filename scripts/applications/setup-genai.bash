#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🤖 Setting up Gen AI tools..."

install_cask_if_missing "ChatGPT.app" chatgpt
install_cask_if_missing "Poe.app" poe

mac_setup_finish "Gen AI tools setup"
