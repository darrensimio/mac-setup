# Shared helpers for mac-setup scripts.
# Source from scripts under scripts/applications/ or scripts/os/:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"

mac_setup_repo_root() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    case "$dir" in
        */scripts/applications | */scripts/os)
            (cd "$dir/../.." && pwd)
            ;;
        */scripts)
            (cd "$dir/.." && pwd)
            ;;
        *)
            (cd "$dir/../.." && pwd)
            ;;
    esac
}

mac_setup_init_paths() {
    REPO_ROOT="$(mac_setup_repo_root)"
    SCRIPTS_DIR="$REPO_ROOT/scripts"
    CONFIGS_DIR="$SCRIPTS_DIR/applications/configs"
}

log_step() {
    echo ""
    echo "==> $*"
}

require_cmd() {
    local cmd missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if ((${#missing[@]} > 0)); then
        echo "Missing required command(s): ${missing[*]}"
        echo "See $REPO_ROOT/README.md#prerequisites"
        return 1
    fi
}

install_mas_app() {
    # $1 App Store ID, $2 display name
    if mas list 2>/dev/null | grep -qw "$1"; then
        echo "✅ $2 is already installed. Skipping..."
        return 0
    fi
    echo "Installing $2..."
    mas install "$1"
}

# Returns 0 if a new install was performed, 1 if already present.
install_cask_if_missing() {
    # $1 app name under /Applications (e.g. "Spotify.app"), $2 brew cask name
    local app_path="/Applications/$1"
    if [[ -d "$app_path" ]]; then
        echo "✅ ${1%.app} is already installed. Skipping..."
        return 1
    fi
    echo "Installing ${1%.app} via Homebrew..."
    brew install --cask "$2"
    return 0
}

ensure_mas_installed() {
    if command -v mas &>/dev/null; then
        echo "✅ mas-cli is already installed. Skipping..."
        return 0
    fi
    echo "mas-cli not found. Installing via Homebrew..."
    brew install mas
}

restore_plist_if_present() {
    # $1 filename in CONFIGS_DIR (e.g. eu.exelban.Stats.plist)
    local src="$CONFIGS_DIR/$1"
    if [[ ! -f "$src" ]]; then
        echo "ℹ️  No $1 found in $CONFIGS_DIR. Skipping restore."
        return 0
    fi
    echo "⚙️  Restoring $(basename "$1" .plist) preferences..."
    cp "$src" "$HOME/Library/Preferences/"
    local domain="${1%.plist}"
    defaults read "$domain" >/dev/null 2>&1 || true
    echo "✅ Preferences restored from $src"
}
