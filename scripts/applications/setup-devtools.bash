#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🛠️  Setting up Developer Tools..."

if install_cask_if_missing "Visual Studio Code.app" visual-studio-code; then
    mac_setup_link_vscode_cli || true
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    mac_setup_link_vscode_cli || true
fi

install_cask_if_missing "Cursor.app" cursor

install_cask_if_missing "Bruno.app" bruno

for pkg in tig gh htop curlie; do
    install_formula_if_missing "$pkg" || true
done

mac_setup_finish "Dev tools setup"
