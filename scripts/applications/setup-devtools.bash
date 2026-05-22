#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew

echo "🛠️  Setting up Developer Tools..."

# Visual Studio Code — symlinks code binary to PATH
if install_cask_if_missing "Visual Studio Code.app" visual-studio-code; then
    echo "Pathing VS Code binary..."
    sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
fi

install_cask_if_missing "Bruno.app" bruno || true

for pkg in tig gh htop curlie; do
    if ! command -v "$pkg" &>/dev/null; then
        echo "Installing $pkg via Homebrew..."
        brew install "$pkg"
    else
        echo "✅ $pkg is already installed. Skipping..."
    fi
done

echo "✅ Dev tools setup complete!"
