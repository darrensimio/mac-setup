#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew || exit 1

echo "🛠️  Setting up Developer Tools..."

if install_cask_if_missing "Visual Studio Code.app" visual-studio-code; then
    mac_setup_run "Symlink VS Code binary" \
        sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
fi

install_cask_if_missing "Bruno.app" bruno

for pkg in tig gh htop curlie; do
    if command -v "$pkg" &>/dev/null; then
        echo "✅ $pkg is already installed. Skipping..."
        continue
    fi
    mac_setup_run "Homebrew formula: $pkg" brew install "$pkg"
done

mac_setup_finish "Dev tools setup"
