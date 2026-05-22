#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths
require_cmd brew

echo "⚙️  Setting up macOS Utilities..."

# mas-cli — install before any App Store apps
ensure_mas_installed

# Moom Classic
# Purpose: Window management utility for moving and zooming windows.
# ID: 419330170
install_mas_app "419330170" "Moom Classic"
if [[ -d "/Applications/Moom Classic.app" ]]; then
    echo "🚀 Launching Moom Classic..."
    open -a "Moom Classic"
fi

# Spotify
# Purpose: Music streaming service.
# Docs: https://www.spotify.com/download/mac/
if install_cask_if_missing "Spotify.app" spotify; then
    echo "🚀 Launching Spotify..."
    open -a Spotify
fi

# Caffeinated
# Purpose: Prevents your Mac from sleeping or dimming.
# Docs: https://macenities.com/caffeinated
install_cask_if_missing "Caffeinated.app" caffeinated

# Hidden Bar
# Purpose: Menu bar organizer to hide inactive icons.
# Docs: https://github.com/dwarvesf/hidden
if install_cask_if_missing "Hidden Bar.app" hiddenbar; then
    echo "🚀 Activating Hidden Bar..."
    open -a "Hidden Bar"
fi

# DisplayLink Manager
# Purpose: Driver software for docking stations and external monitors.
# Docs: https://www.synaptics.com/products/displaylink-graphics
install_cask_if_missing "DisplayLink Manager.app" displaylink

# Stats
# Purpose: Open-source system monitor for the menu bar (CPU, GPU, RAM, Network).
# Docs: https://github.com/exelban/stats
if ! command -v stats &>/dev/null && [[ ! -d "/Applications/Stats.app" ]]; then
    echo "Installing Stats via Homebrew..."
    brew install --cask stats
else
    echo "✅ Stats is already installed. Skipping..."
fi

restore_plist_if_present "eu.exelban.Stats.plist"

# Jabra Direct
# Purpose: Optimize and personalize Jabra headset/speakerphone settings.
if install_cask_if_missing "Jabra Direct.app" jabra-direct; then
    echo "🚀 Launching Jabra Direct..."
    open -a "Jabra Direct"
fi

# Logi Options+
# Purpose: Customize Logitech mice, keyboards, and webcams.
if install_cask_if_missing "Logi Options+.app" logi-options+; then
    echo "🚀 Launching Logi Options+..."
    open -a "Logi Options+"
fi

echo "✅ Utilities setup complete!"
