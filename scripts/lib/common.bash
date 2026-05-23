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

MAC_SETUP_FAILURES=0

log_step() {
    echo ""
    echo "==> $*"
}

mac_setup_record_failure() {
    local label="$1"
    echo "❌ Failed: $label"
    MAC_SETUP_FAILURES=$((MAC_SETUP_FAILURES + 1))
}

# Run a command; on failure log and continue (do not exit the script).
mac_setup_run() {
    local label="$1"
    shift
    if "$@"; then
        return 0
    fi
    mac_setup_record_failure "$label"
    return 0
}

mac_setup_finish() {
    local script_name="${1:-script}"
    if (( MAC_SETUP_FAILURES > 0 )); then
        echo ""
        echo "⚠️  $script_name finished with $MAC_SETUP_FAILURES failure(s)."
        exit 1
    fi
    echo "✅ $script_name complete!"
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
    mac_setup_run "App Store: $2" mas install "$1"
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
    if brew install --cask "$2"; then
        return 0
    fi
    mac_setup_record_failure "Homebrew cask: ${1%.app}"
    return 1
}

ensure_mas_installed() {
    if command -v mas &>/dev/null; then
        echo "✅ mas-cli is already installed. Skipping..."
        return 0
    fi
    echo "mas-cli not found. Installing via Homebrew..."
    mac_setup_run "Homebrew: mas" brew install mas
}

restore_plist_if_present() {
    # $1 filename in CONFIGS_DIR (e.g. eu.exelban.Stats.plist)
    local src="$CONFIGS_DIR/$1"
    if [[ ! -f "$src" ]]; then
        echo "ℹ️  No $1 found in $CONFIGS_DIR. Skipping restore."
        return 0
    fi
    mac_setup_run "Restore preferences: $1" cp "$src" "$HOME/Library/Preferences/"
    local domain="${1%.plist}"
    defaults read "$domain" >/dev/null 2>&1 || true
    echo "✅ Preferences restored from $src"
}

MAC_SETUP_SUDO_REFRESH_PID=""

# Prompt for admin password once and keep credentials valid for the rest of the run.
# Child scripts (separate bash processes) reuse the same cached sudo timestamp.
mac_setup_acquire_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi
    echo ""
    echo "Administrator access is needed for some app installers (e.g. .pkg casks) and system tools."
    echo "Enter your password once — it will stay valid for the rest of this setup run."
    echo ""
    if ! sudo -v; then
        echo "Could not obtain administrator privileges."
        return 1
    fi
    if [[ -n "${MAC_SETUP_SUDO_REFRESH_PID:-}" ]]; then
        kill "$MAC_SETUP_SUDO_REFRESH_PID" 2>/dev/null || true
    fi
    (
        while true; do
            sleep 60
            sudo -n true 2>/dev/null || exit
        done
    ) &
    MAC_SETUP_SUDO_REFRESH_PID=$!
    export MAC_SETUP_SUDO_READY=1
    return 0
}

mac_setup_release_sudo() {
    if [[ -n "${MAC_SETUP_SUDO_REFRESH_PID:-}" ]]; then
        kill "$MAC_SETUP_SUDO_REFRESH_PID" 2>/dev/null || true
        MAC_SETUP_SUDO_REFRESH_PID=""
    fi
}

# Symlink VS Code CLI without sudo (user-local bin directory).
mac_setup_link_vscode_cli() {
    local vscode_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    local local_bin="$HOME/.local/bin"
    if [[ ! -x "$vscode_bin" ]]; then
        mac_setup_record_failure "VS Code CLI: binary not found"
        return 1
    fi
    mkdir -p "$local_bin"
    ln -sf "$vscode_bin" "$local_bin/code"
    if [[ -f "$HOME/.zprofile" ]] && ! grep -qF '.local/bin' "$HOME/.zprofile" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zprofile"
        echo "Added ~/.local/bin to PATH in ~/.zprofile"
    elif [[ ! -f "$HOME/.zprofile" ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zprofile"
        echo "Created ~/.zprofile with ~/.local/bin on PATH"
    fi
    echo "✅ VS Code CLI available as: code (~/.local/bin/code)"
}
