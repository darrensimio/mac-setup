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
    MAC_SETUP_REPORT_FILE="${MAC_SETUP_REPORT_FILE:-$REPO_ROOT/.mac-setup-last-run.tsv}"
    MAC_SETUP_ERRORS_FILE="${MAC_SETUP_ERRORS_FILE:-$REPO_ROOT/.mac-setup-last-run-errors.log}"
    export MAC_SETUP_REPORT_FILE MAC_SETUP_ERRORS_FILE
}

mac_setup_report_begin() {
    mac_setup_init_paths
    MAC_SETUP_REPORT_FILE="$REPO_ROOT/.mac-setup-last-run.tsv"
    MAC_SETUP_ERRORS_FILE="$REPO_ROOT/.mac-setup-last-run-errors.log"
    export MAC_SETUP_REPORT_FILE MAC_SETUP_ERRORS_FILE
    : >"$MAC_SETUP_REPORT_FILE"
    : >"$MAC_SETUP_ERRORS_FILE"
}

mac_setup_report() {
    local status="$1"
    local item="$2"
    local detail="${3:-}"
    mac_setup_init_paths
    printf '%s\t%s\t%s\n' "$status" "$item" "$detail" >>"$MAC_SETUP_REPORT_FILE"
}

mac_setup_report_failed() {
    local item="$1"
    local error_log="${2:-}"
    local short="${3:-}"
    mac_setup_init_paths
    mac_setup_report "failed" "$item" "$short"
    if [[ -n "$error_log" ]]; then
        {
            echo "### $item"
            if [[ -n "$short" ]]; then
                echo "Command: $short"
            fi
            echo "$error_log"
            echo "---"
        } >>"$MAC_SETUP_ERRORS_FILE"
    fi
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

mac_setup_run() {
    local label="$1"
    shift
    local out
    out=$("$@" 2>&1) && return 0
    echo "$out" >&2
    mac_setup_record_failure "$label"
    mac_setup_report_failed "$label" "$out" "$*"
    return 0
}

mac_setup_print_summary() {
    mac_setup_init_paths
    if [[ ! -s "$MAC_SETUP_REPORT_FILE" ]]; then
        echo ""
        echo "No install results recorded."
        return 0
    fi

    echo ""
    echo "Setup summary"
    echo ""
    printf "| %-36s | %-22s |\n" "Item" "Status"
    printf "| %-36s | %-22s |\n" "------------------------------------" "------------------------"

    local status item detail label
    while IFS=$'\t' read -r status item detail; do
        case "$status" in
            installed)  label="Installed" ;;
            already)    label="Already installed" ;;
            failed)     label="Failed" ;;
            skipped)    label="Skipped" ;;
            completed)  label="Completed" ;;
            *)          label="$status" ;;
        esac
        printf "| %-36s | %-22s |\n" "$item" "$label"
    done <"$MAC_SETUP_REPORT_FILE"

    local installed already failed skipped completed
    installed=$(grep -c $'^installed\t' "$MAC_SETUP_REPORT_FILE" 2>/dev/null || echo 0)
    already=$(grep -c $'^already\t' "$MAC_SETUP_REPORT_FILE" 2>/dev/null || echo 0)
    failed=$(grep -c $'^failed\t' "$MAC_SETUP_REPORT_FILE" 2>/dev/null || echo 0)
    skipped=$(grep -c $'^skipped\t' "$MAC_SETUP_REPORT_FILE" 2>/dev/null || echo 0)
    completed=$(grep -c $'^completed\t' "$MAC_SETUP_REPORT_FILE" 2>/dev/null || echo 0)

    echo ""
    echo "Totals: $installed installed, $already already present, $completed completed, $failed failed, $skipped skipped"

    if [[ "${failed:-0}" -gt 0 && -s "$MAC_SETUP_ERRORS_FILE" ]]; then
        echo ""
        echo "Failure details"
        echo ""
        cat "$MAC_SETUP_ERRORS_FILE"
    fi
}

mac_setup_finish() {
    local script_name="${1:-script}"
    if [[ -z "${MAC_SETUP_ORCHESTRATED:-}" ]]; then
        mac_setup_print_summary
    fi
    if (( MAC_SETUP_FAILURES > 0 )); then
        echo ""
        echo "⚠️  $script_name finished with $MAC_SETUP_FAILURES failure(s)."
        exit 1
    fi
    echo ""
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
    local id="$1"
    local name="$2"
    if mas list 2>/dev/null | grep -qw "$id"; then
        echo "✅ $name is already installed. Skipping..."
        mac_setup_report "already" "$name"
        return 0
    fi
    echo "Installing $name (App Store ID $id)..."
    local mas_out mas_status
    mas_out=$(mas install "$id" 2>&1) && mas_status=0 || mas_status=$?
    if [[ $mas_status -eq 0 ]]; then
        mac_setup_report "installed" "$name"
        return 0
    fi
    echo "$mas_out" >&2
    mac_setup_record_failure "App Store: $name"
    mac_setup_report_failed "$name" "$mas_out" "mas install $id"
    return 0
}

install_cask_if_missing() {
    local app_file="$1"
    local cask="$2"
    local name="${app_file%.app}"
    local app_path="/Applications/$app_file"
    if [[ -d "$app_path" ]]; then
        echo "✅ $name is already installed. Skipping..."
        mac_setup_report "already" "$name"
        return 1
    fi
    echo "Installing $name via Homebrew..."
    local brew_out brew_status
    brew_out=$(brew install --cask "$cask" 2>&1) && brew_status=0 || brew_status=$?
    if [[ $brew_status -eq 0 ]]; then
        mac_setup_report "installed" "$name"
        return 0
    fi
    echo "$brew_out" >&2
    mac_setup_record_failure "Homebrew cask: $name"
    mac_setup_report_failed "$name" "$brew_out" "brew install --cask $cask"
    return 1
}

install_formula_if_missing() {
    local pkg="$1"
    if command -v "$pkg" &>/dev/null; then
        echo "✅ $pkg is already installed. Skipping..."
        mac_setup_report "already" "$pkg"
        return 1
    fi
    echo "Installing $pkg via Homebrew..."
    local brew_out brew_status
    brew_out=$(brew install "$pkg" 2>&1) && brew_status=0 || brew_status=$?
    if [[ $brew_status -eq 0 ]]; then
        mac_setup_report "installed" "$pkg"
        return 0
    fi
    echo "$brew_out" >&2
    mac_setup_record_failure "Homebrew formula: $pkg"
    mac_setup_report_failed "$pkg" "$brew_out" "brew install $pkg"
    return 1
}

ensure_mas_installed() {
    if command -v mas &>/dev/null; then
        echo "✅ mas-cli is already installed. Skipping..."
        mac_setup_report "already" "mas-cli"
        return 0
    fi
    echo "mas-cli not found. Installing via Homebrew..."
    local brew_out brew_status
    brew_out=$(brew install mas 2>&1) && brew_status=0 || brew_status=$?
    if [[ $brew_status -eq 0 ]]; then
        mac_setup_report "installed" "mas-cli"
        return 0
    fi
    echo "$brew_out" >&2
    mac_setup_record_failure "Homebrew: mas"
    mac_setup_report_failed "mas-cli" "$brew_out" "brew install mas"
    return 0
}

mac_setup_pref_dest() {
    local file="$1"
    echo "$HOME/Library/Preferences/$(basename "$file")"
}

# Prints: no_source | not_applied | applied
mac_setup_config_status() {
    local file="$1"
    local src="$CONFIGS_DIR/$file"
    local dest
    dest="$(mac_setup_pref_dest "$file")"
    if [[ ! -f "$src" ]]; then
        echo "no_source"
        return 0
    fi
    if [[ ! -f "$dest" ]]; then
        echo "not_applied"
        return 0
    fi
    if cmp -s "$src" "$dest"; then
        echo "applied"
        return 0
    fi
    echo "not_applied"
}

restore_plist_if_present() {
    local file="$1"
    local src="$CONFIGS_DIR/$file"
    local pref_name dest domain
    pref_name="$(basename "$file")"
    dest="$(mac_setup_pref_dest "$file")"
    domain="${pref_name%.plist}"
    if [[ ! -f "$src" ]]; then
        echo "ℹ️  No $file found in $CONFIGS_DIR. Skipping restore."
        mac_setup_report "skipped" "Preferences: $domain"
        return 0
    fi
    if cp "$src" "$dest"; then
        defaults read "$domain" >/dev/null 2>&1 || true
        echo "✅ Preferences restored from $src"
        mac_setup_report "completed" "Preferences: $domain"
        return 0
    fi
    mac_setup_record_failure "Restore preferences: $file"
    mac_setup_report_failed "Preferences: $domain" "cp failed for $src" "cp $src $dest"
    return 0
}

MAC_SETUP_SUDO_REFRESH_PID=""

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

mac_setup_link_vscode_cli() {
    local vscode_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    local local_bin="$HOME/.local/bin"
    if [[ ! -x "$vscode_bin" ]]; then
        mac_setup_record_failure "VS Code CLI: binary not found"
        mac_setup_report_failed "VS Code CLI (code command)" "VS Code binary not found at $vscode_bin"
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
    mac_setup_report "completed" "VS Code CLI (code command)"
    return 0
}
