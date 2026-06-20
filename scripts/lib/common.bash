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
    local container_id="${2:-}"
    local pref_name
    pref_name="$(basename "$file")"
    if [[ -n "$container_id" ]]; then
        echo "$HOME/Library/Containers/$container_id/Data/Library/Preferences/$pref_name"
        return 0
    fi
    echo "$HOME/Library/Preferences/$pref_name"
}

# Prints: no_source | not_applied | applied
mac_setup_config_status() {
    local file="$1"
    local container_id="${2:-}"
    local src="$CONFIGS_DIR/$file"
    local dest
    dest="$(mac_setup_pref_dest "$file" "$container_id")"
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

# True when new-message sound is off (None, empty, or key absent).
mac_setup_mail_new_message_sound_off() {
    local current
    if ! current="$(defaults read -app Mail NewMessagesSoundName 2>/dev/null)"; then
        return 0
    fi
    [[ -z "$current" || "$current" == "None" ]]
}

# Prints: applied | not_applied | unavailable
mac_setup_mail_new_message_sound_status() {
    if ! defaults read -app Mail &>/dev/null; then
        echo "unavailable"
        return 0
    fi
    if mac_setup_mail_new_message_sound_off; then
        echo "applied"
        return 0
    fi
    echo "not_applied"
}

# True when "Play sounds for other mail actions" is off.
mac_setup_mail_play_sounds_off() {
    local play
    if ! play="$(defaults read -app Mail PlayMailSounds 2>/dev/null)"; then
        return 0
    fi
    [[ "$play" == "0" || "$play" == "false" || "$play" == "False" ]]
}

# Prints: applied | not_applied | unavailable
mac_setup_mail_play_sounds_status() {
    if ! defaults read -app Mail &>/dev/null; then
        echo "unavailable"
        return 0
    fi
    if mac_setup_mail_play_sounds_off; then
        echo "applied"
        return 0
    fi
    echo "not_applied"
}

# True when battery percentage is shown in the menu bar.
mac_setup_battery_show_percentage_on() {
    local value
    if ! value="$(defaults -currentHost read com.apple.controlcenter BatteryShowPercentage 2>/dev/null)"; then
        return 1
    fi
    [[ "$value" == "1" || "$value" == "true" || "$value" == "TRUE" ]]
}

# Prints: applied | not_applied | unavailable
mac_setup_battery_show_percentage_status() {
    if mac_setup_battery_show_percentage_on; then
        echo "applied"
        return 0
    fi
    if defaults -currentHost read com.apple.controlcenter &>/dev/null; then
        echo "not_applied"
        return 0
    fi
    echo "unavailable"
}

mac_setup_mail_apply_sound_prefs() {
    defaults delete -app Mail NewMessagesSoundName 2>/dev/null || true
    defaults write -app Mail NewMessagesSoundName -string "None" 2>/dev/null || true
    defaults write -app Mail MailSound -string "" 2>/dev/null || true
    defaults write -app Mail PlayMailSounds -bool false 2>/dev/null || true
}

mac_setup_mail_apply_sound_prefs_ui() {
    osascript <<'APPLESCRIPT' 2>/dev/null
tell application "Mail" to activate
delay 1
tell application "System Events"
    keystroke "," using command down
    delay 1.5
    tell process "Mail"
        try
            if exists button "General" of toolbar 1 of window 1 then
                click button "General" of toolbar 1 of window 1
            end if
        end try
        delay 0.6
        repeat with pb in (every pop up button of window 1)
            try
                set pbName to name of pb
                set pbDesc to description of pb
                if pbName contains "sound" or pbDesc contains "sound" or pbName contains "Sound" or pbDesc contains "Sound" then
                    if value of pb is not "None" then
                        click pb
                        delay 0.4
                        click menu item "None" of menu 1 of pb
                    end if
                end if
            end try
        end repeat
        repeat with cb in (every checkbox of window 1)
            try
                if (name of cb contains "Play sounds") or (description of cb contains "Play sounds") then
                    if value of cb is 1 then click cb
                end if
            end try
        end repeat
        try
            click button 1 of window 1
        end try
    end tell
end tell
APPLESCRIPT
}

restore_plist_if_present() {
    local file="$1"
    local container_id="${2:-}"
    local src="$CONFIGS_DIR/$file"
    local pref_name dest domain
    pref_name="$(basename "$file")"
    dest="$(mac_setup_pref_dest "$file" "$container_id")"
    domain="${pref_name%.plist}"
    if [[ ! -f "$src" ]]; then
        echo "ℹ️  No $file found in $CONFIGS_DIR. Skipping restore."
        mac_setup_report "skipped" "Preferences: $domain"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if cp "$src" "$dest"; then
        defaults read "$domain" >/dev/null 2>&1 || true
        if [[ -n "$container_id" ]]; then
            echo "✅ Preferences restored to app container: $dest"
        else
            echo "✅ Preferences restored from $src"
        fi
        mac_setup_report "completed" "Preferences: $domain"
        return 0
    fi
    mac_setup_record_failure "Restore preferences: $file"
    mac_setup_report_failed "Preferences: $domain" "cp failed for $src" "cp $src $dest"
    return 0
}

mac_setup_prefs_dir_dest() {
    local kind="$1"
    local id="$2"
    case "$kind" in
        container) echo "$HOME/Library/Containers/$id/Data/Library/Preferences" ;;
        group) echo "$HOME/Library/Group Containers/$id/Library/Preferences" ;;
        *) return 1 ;;
    esac
}

# Prints: no_source | not_applied | applied
mac_setup_config_dir_status() {
    local rel_dir="$1"
    local kind="$2"
    local id="$3"
    local src="$CONFIGS_DIR/$rel_dir"
    local dest f base
    if ! compgen -G "$src/*.plist" >/dev/null; then
        echo "no_source"
        return 0
    fi
    dest="$(mac_setup_prefs_dir_dest "$kind" "$id")" || { echo "unavailable"; return 0; }
    for f in "$src"/*.plist; do
        [[ -f "$f" ]] || continue
        base="$(basename "$f")"
        if [[ ! -f "$dest/$base" ]] || ! cmp -s "$f" "$dest/$base"; then
            echo "not_applied"
            return 0
        fi
    done
    echo "applied"
}

restore_prefs_dir_if_present() {
    local rel_dir="$1"
    local kind="$2"
    local id="$3"
    local label="$4"
    local src="$CONFIGS_DIR/$rel_dir"
    local dest f base copied=0
    if ! compgen -G "$src/*.plist" >/dev/null; then
        echo "ℹ️  No plists in $rel_dir. Skipping restore."
        mac_setup_report "skipped" "Preferences: $label"
        return 0
    fi
    dest="$(mac_setup_prefs_dir_dest "$kind" "$id")" || {
        mac_setup_record_failure "Restore preferences: $label"
        mac_setup_report_failed "Preferences: $label" "unknown prefs dir kind: $kind" "restore_prefs_dir_if_present"
        return 0
    }
    mkdir -p "$dest"
    for f in "$src"/*.plist; do
        [[ -f "$f" ]] || continue
        base="$(basename "$f")"
        if cp "$f" "$dest/$base"; then
            copied=$((copied + 1))
            defaults read "${base%.plist}" >/dev/null 2>&1 || true
        fi
    done
    if (( copied > 0 )); then
        echo "✅ Restored $copied preference file(s) for $label → $dest"
        mac_setup_report "completed" "Preferences: $label"
        return 0
    fi
    mac_setup_record_failure "Restore preferences: $label"
    mac_setup_report_failed "Preferences: $label" "cp failed for $src/*.plist" "cp $src/*.plist $dest/"
    return 0
}

restore_hour_prefs_if_present() {
    restore_prefs_dir_if_present "hour-world-clock/container" "container" "com.fabriceleyne.hourlite" "Hour - World Clock"
    restore_prefs_dir_if_present "hour-world-clock/group" "group" "3EYN7PPTPF.com.fabriceleyne.hourlite" "Hour - World Clock (group)"
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
