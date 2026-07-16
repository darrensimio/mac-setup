#!/usr/bin/env bash
# Report installed apps and applied configs vs repo desired state (read-only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.bash
source "$SCRIPT_DIR/lib/common.bash"
mac_setup_init_paths

PLAN_USE_COLOR=false
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    PLAN_USE_COLOR=true
fi

plan_style() {
    local style="$1"
    shift
    local text="$*"
    if ! $PLAN_USE_COLOR; then
        printf '%s' "$text"
        return 0
    fi
    case "$style" in
        ok) printf '\033[32m%s\033[0m' "$text" ;;
        warn) printf '\033[33m%s\033[0m' "$text" ;;
        bad) printf '\033[31m%s\033[0m' "$text" ;;
        dim) printf '\033[2m%s\033[0m' "$text" ;;
        bold) printf '\033[1m%s\033[0m' "$text" ;;
        *) printf '%s' "$text" ;;
    esac
}

plan_style_yes_no() {
    if [[ "$1" == "yes" ]]; then
        plan_style ok "yes"
    else
        plan_style dim "no"
    fi
}

# group|name|kind|arg1|arg2 (optional app file for mas)
PLAN_APPS=(
    "office|Microsoft Word|mas|462054704|Microsoft Word.app"
    "office|Microsoft Excel|mas|462058435|Microsoft Excel.app"
    "office|Microsoft PowerPoint|mas|462062816|Microsoft PowerPoint.app"
    "office|Windows App|mas|1295203466|Windows App.app"
    "office|Microsoft Teams|cask|Microsoft Teams.app|"
    "office|Microsoft Edge|cask|Microsoft Edge.app|"
    "office|Pages|mas|361309726|Pages.app"
    "office|Numbers|mas|361304891|Numbers.app"
    "office|Keynote|mas|361285480|Keynote.app"
    "office|Proton Mail|cask|Proton Mail.app|"
    "office|Proton Pass|cask|Proton Pass.app|"
    "office|Proton VPN|cask|Proton VPN.app|"
    "office|1Password|cask|1Password.app|"
    "office|Notion|cask|Notion.app|"
    "office|Google Chrome|cask|Google Chrome.app|"
    "office|Zoom|cask|zoom.us.app|"
    "office|Slack|mas|803453959|Slack.app"
    "office|WhatsApp|mas|310633997|WhatsApp.app"
    "office|Telegram|mas|747648890|Telegram.app"
    "devtools|Visual Studio Code|cask|Visual Studio Code.app|"
    "devtools|Cursor|cask|Cursor.app|"
    "devtools|Bruno|cask|Bruno.app|"
    "devtools|tig|formula|tig|"
    "devtools|gh|formula|gh|"
    "devtools|htop|formula|htop|"
    "devtools|curlie|formula|curlie|"
    "devtools|VS Code CLI (code)|link|$HOME/.local/bin/code|"
    "terminal|iTerm2|cask|iTerm.app|"
    "terminal|Oh My Zsh|dir|$HOME/.oh-my-zsh|"
    "utils|mas-cli|formula|mas|"
    "utils|Moom Classic|mas|419330170|Moom Classic.app"
    "utils|Spotify|cask|Spotify.app|"
    "utils|Caffeinated|mas|1362171212|Caffeinated.app"
    "utils|Post-it|mas|1475777828|Post-it.app"
    "utils|Hour - World Clock|mas|569089415|Hour.app"
    "utils|Hidden Bar|cask|Hidden Bar.app|"
    "utils|DisplayLink Manager|cask|DisplayLink Manager.app|"
    "utils|OneDrive|cask|OneDrive.app|"
    "utils|Google Drive|cask|Google Drive.app|"
    "utils|Jabra Direct|cask|Jabra Direct.app|"
    "utils|Logitech Options+|cask|logioptionsplus.app|"
    "utils|Stats|cask|Stats.app|"
    "genai|ChatGPT|cask|ChatGPT.app|"
    "genai|Poe|cask|Poe.app|"
)

# group|label|config_path|optional_app_file|optional_container_id
PLAN_CONFIGS=(
    "utils|Moom Classic|moom-classic/com.manytricks.Moom.plist|Moom Classic.app|"
    "utils|Hidden Bar|hidden-bar/com.dwarvesv.minimalbar.plist|Hidden Bar.app|com.dwarvesv.minimalbar"
    "utils|Stats|eu.exelban.Stats.plist|Stats.app|"
)

# group|label|rel_dir|optional_app_file|prefs_kind|prefs_id  (prefs_kind: container | group)
PLAN_CONFIG_DIRS=(
    "utils|Hour - World Clock|hour-world-clock/container|Hour.app|container|com.fabriceleyne.hourlite"
    "utils|Hour - World Clock (group)|hour-world-clock/group|Hour.app|group|3EYN7PPTPF.com.fabriceleyne.hourlite"
)

plan_app_installed() {
    local kind="$1" arg1="$2" arg2="${3:-}"
    case "$kind" in
        mas)
            if command -v mas &>/dev/null && mas list 2>/dev/null | grep -qw "$arg1"; then
                return 0
            fi
            [[ -n "$arg2" && -d "/Applications/$arg2" ]]
            ;;
        cask)
            [[ -d "/Applications/$arg1" ]]
            ;;
        formula)
            command -v "$arg1" &>/dev/null
            ;;
        dir)
            [[ -d "$arg1" ]]
            ;;
        link)
            [[ -x "$arg1" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

plan_print_apps() {
    local drift=0
    echo "Applications"
    echo ""
    printf "| %-10s | %-28s | %-18s |\n" "Group" "Item" "Install"
    printf "| %-10s | %-28s | %-18s |\n" "----------" "----------------------------" "------------------"

    local entry group name kind arg1 arg2 status_col
    for entry in "${PLAN_APPS[@]}"; do
        IFS='|' read -r group name kind arg1 arg2 <<<"$entry"
        if plan_app_installed "$kind" "$arg1" "$arg2"; then
            status_col="$(plan_style ok "installed")"
        else
            status_col="$(plan_style warn "not installed")"
            drift=1
        fi
        printf "| %-10s | %-28s | %b |\n" "$group" "$name" "$status_col"
    done

    echo ""
    return "$drift"
}

plan_print_configs() {
    local drift=0
    echo "Configuration (preference plists)"
    echo ""
    printf "| %-10s | %-18s | %-10s | %-12s | %-18s |\n" "Group" "Item" "In repo" "On machine" "Status"
    printf "| %-10s | %-18s | %-10s | %-12s | %-18s |\n" "----------" "------------------" "----------" "------------" "------------------"

    local entry group label file app_file container_id src dest
    local in_repo_raw on_machine_raw in_repo_col on_machine_col status_col app_ok_col
    for entry in "${PLAN_CONFIGS[@]}"; do
        IFS='|' read -r group label file app_file container_id <<<"$entry"
        src="$CONFIGS_DIR/$file"
        dest="$(mac_setup_pref_dest "$file" "$container_id")"

        if [[ -f "$src" ]]; then
            in_repo_raw="yes"
        else
            in_repo_raw="no"
        fi
        in_repo_col="$(plan_style_yes_no "$in_repo_raw")"

        if [[ -f "$dest" ]]; then
            on_machine_raw="yes"
        else
            on_machine_raw="no"
        fi
        on_machine_col="$(plan_style_yes_no "$on_machine_raw")"

        case "$(mac_setup_config_status "$file" "$container_id")" in
            no_source)
                status_col="$(plan_style dim "no source in repo")"
                ;;
            not_applied)
                if [[ "$in_repo_raw" == "yes" ]]; then
                    status_col="$(plan_style warn "not applied")"
                    drift=1
                else
                    status_col="$(plan_style dim "no source in repo")"
                fi
                ;;
            applied)
                status_col="$(plan_style ok "applied")"
                ;;
        esac

        if [[ -n "$app_file" ]]; then
            if [[ -d "/Applications/$app_file" ]]; then
                app_ok_col="$(plan_style dim "(app installed)")"
            else
                app_ok_col="$(plan_style warn "(app not installed)")"
            fi
        else
            app_ok_col=""
        fi

        printf "| %-10s | %-18s | %b | %b | %b %b\n" \
            "$group" "$label" "$in_repo_col" "$on_machine_col" "$status_col" "$app_ok_col"
    done

    local rel_dir kind id dest_dir
    for entry in "${PLAN_CONFIG_DIRS[@]}"; do
        IFS='|' read -r group label rel_dir app_file kind id <<<"$entry"
        src="$CONFIGS_DIR/$rel_dir"
        dest_dir="$(mac_setup_prefs_dir_dest "$kind" "$id")" || dest_dir=""

        if compgen -G "$src/*.plist" >/dev/null; then
            in_repo_raw="yes"
        else
            in_repo_raw="no"
        fi
        in_repo_col="$(plan_style_yes_no "$in_repo_raw")"

        if [[ -n "$dest_dir" ]] && compgen -G "$dest_dir/*.plist" >/dev/null; then
            on_machine_raw="yes"
        else
            on_machine_raw="no"
        fi
        on_machine_col="$(plan_style_yes_no "$on_machine_raw")"

        case "$(mac_setup_config_dir_status "$rel_dir" "$kind" "$id")" in
            no_source)
                status_col="$(plan_style dim "no source in repo")"
                ;;
            not_applied)
                if [[ "$in_repo_raw" == "yes" ]]; then
                    status_col="$(plan_style warn "not applied")"
                    drift=1
                else
                    status_col="$(plan_style dim "no source in repo")"
                fi
                ;;
            applied)
                status_col="$(plan_style ok "applied")"
                ;;
        esac

        if [[ -n "$app_file" ]]; then
            if [[ -d "/Applications/$app_file" ]]; then
                app_ok_col="$(plan_style dim "(app installed)")"
            else
                app_ok_col="$(plan_style warn "(app not installed)")"
            fi
        else
            app_ok_col=""
        fi

        printf "| %-10s | %-18s | %b | %b | %b %b\n" \
            "$group" "$label" "$in_repo_col" "$on_machine_col" "$status_col" "$app_ok_col"
    done

    echo ""
    return "$drift"
}

plan_os_setting_row() {
    local group="$1" label="$2" desired="$3" current_display="$4" status="$5"
    local status_col
    case "$status" in
        applied) status_col="$(plan_style ok "applied")" ;;
        not_applied) status_col="$(plan_style warn "not applied")" ;;
        *) status_col="$(plan_style dim "unavailable")" ;;
    esac
    printf "| %-10s | %-22s | %b | %-14s | %b |\n" \
        "$group" "$label" "$(plan_style ok "$desired")" "$current_display" "$status_col"
}

plan_print_os_settings() {
    local drift=0
    echo "OS settings"
    echo ""
    printf "| %-10s | %-22s | %-10s | %-14s | %-18s |\n" "Group" "Item" "Desired" "On machine" "Status"
    printf "| %-10s | %-22s | %-10s | %-14s | %-18s |\n" "----------" "----------------------" "----------" "--------------" "------------------"

    local current status
    current="$(defaults read -app Mail NewMessagesSoundName 2>/dev/null || true)"
    [[ -n "$current" ]] || current="<unset>"
    status="$(mac_setup_mail_new_message_sound_status)"
    plan_os_setting_row "os" "Mail: new msg sound" "None" "$current" "$status"
    [[ "$status" == "applied" ]] || drift=1

    current="$(defaults read -app Mail PlayMailSounds 2>/dev/null || true)"
    [[ -n "$current" ]] || current="<unset>"
    status="$(mac_setup_mail_play_sounds_status)"
    plan_os_setting_row "os" "Mail: other sounds" "off" "$current" "$status"
    [[ "$status" == "applied" ]] || drift=1

    current="$(defaults -currentHost read com.apple.controlcenter BatteryShowPercentage 2>/dev/null || true)"
    [[ -n "$current" ]] || current="<unset>"
    status="$(mac_setup_battery_show_percentage_status)"
    plan_os_setting_row "os" "Battery: show %" "on" "$current" "$status"
    [[ "$status" == "applied" ]] || drift=1

    current="$(defaults read com.apple.screencapture location 2>/dev/null || true)"
    [[ -n "$current" ]] || current="<unset>"
    status="$(mac_setup_screenshot_location_status "$HOME/screenshot")"
    plan_os_setting_row "os" "Screenshots: folder" "~/screenshot" "$current" "$status"
    [[ "$status" == "applied" ]] || drift=1

    current="$(defaults read com.apple.screencapture disable-sound 2>/dev/null || true)"
    [[ -n "$current" ]] || current="<unset>"
    status="$(mac_setup_screenshot_disable_sound_status)"
    plan_os_setting_row "os" "Screenshots: sound" "off" "$current" "$status"
    [[ "$status" == "applied" ]] || drift=1

    echo ""
    return "$drift"
}

plan_print_dock() {
    echo "Dock"
    echo ""
    if bash "$SCRIPTS_DIR/os/setup-dock.bash" --check; then
        echo ""
        return 0
    fi
    echo ""
    return 1
}

main() {
    local app_drift=0 config_drift=0 os_drift=0 dock_drift=0

    echo "mac-setup plan (read-only)"
    echo "Compares this machine to packages and configs defined in the repo."
    echo ""

    plan_print_apps || app_drift=$?
    plan_print_configs || config_drift=$?
    plan_print_os_settings || os_drift=$?
    plan_print_dock || dock_drift=$?

    echo "Legend:"
    if $PLAN_USE_COLOR; then
        echo "  $(plan_style ok "green") = installed / applied / yes"
        echo "  $(plan_style warn "yellow") = not installed / not applied (setup would change)"
        echo "  $(plan_style dim "dim") = no / no source in repo"
    else
        echo "  Applications: installed = present on this Mac; not installed = setup would install"
        echo "  Configuration: applied = ~/Library/Preferences matches repo; not applied = repo has a plist but machine differs or is missing"
        echo "  OS settings: applied = matches setup-os scripts (e.g. Mail new message sound = None)"
    fi
    echo "  Dock: run setup with --include-dock to apply"
    echo "  Set NO_COLOR=1 or pipe output to disable colors."
    echo ""

    if (( app_drift == 0 && config_drift == 0 && os_drift == 0 && dock_drift == 0 )); then
        echo "$(plan_style ok "✅ Plan: machine matches desired apps, configs, OS settings, and Dock.")"
        exit 0
    fi

    echo "$(plan_style warn "⚠️  Plan: drift detected. Run setup to install missing apps or apply configs:")"
    echo "    bash scripts/setup.sh"
    echo "    bash scripts/setup.sh --apps-only          # apps + preference restores"
    echo "    bash scripts/setup.sh --os-only --skip display --skip widget --skip dock   # Mail + other OS (not Dock)"
    echo "    bash scripts/os/setup-mail.bash            # Mail only"
    echo "    bash scripts/setup.sh --os-only --skip display --skip widget --include-dock   # Dock only"
    exit 1
}

main "$@"
