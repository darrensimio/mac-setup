#!/usr/bin/env bash
# Report installed apps and applied configs vs repo desired state (read-only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.bash
source "$SCRIPT_DIR/lib/common.bash"
mac_setup_init_paths

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
    "utils|Hidden Bar|cask|Hidden Bar.app|"
    "utils|DisplayLink Manager|cask|DisplayLink Manager.app|"
    "utils|Stats|cask|Stats.app|"
)

# group|label|config_path|optional_app_file (under /Applications)
PLAN_CONFIGS=(
    "utils|Moom Classic|moom-classic/com.manytricks.Moom.plist|Moom Classic.app"
    "utils|Stats|eu.exelban.Stats.plist|Stats.app"
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

    local entry group name kind arg1 arg2 status
    for entry in "${PLAN_APPS[@]}"; do
        IFS='|' read -r group name kind arg1 arg2 <<<"$entry"
        if plan_app_installed "$kind" "$arg1" "$arg2"; then
            status="installed"
        else
            status="not installed"
            drift=1
        fi
        printf "| %-10s | %-28s | %-18s |\n" "$group" "$name" "$status"
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

    local entry group label file app_file src dest in_repo on_machine status app_ok
    for entry in "${PLAN_CONFIGS[@]}"; do
        IFS='|' read -r group label file app_file <<<"$entry"
        src="$CONFIGS_DIR/$file"
        dest="$(mac_setup_pref_dest "$file")"

        if [[ -f "$src" ]]; then
            in_repo="yes"
        else
            in_repo="no"
        fi

        if [[ -f "$dest" ]]; then
            on_machine="yes"
        else
            on_machine="no"
        fi

        status="$(mac_setup_config_status "$file")"
        case "$status" in
            no_source) status="no source in repo" ;;
            not_applied)
                if [[ "$in_repo" == "yes" ]]; then
                    status="not applied"
                    drift=1
                else
                    status="no source in repo"
                fi
                ;;
            applied) status="applied" ;;
        esac

        if [[ -n "$app_file" ]]; then
            if [[ -d "/Applications/$app_file" ]]; then
                app_ok="(app installed)"
            else
                app_ok="(app not installed)"
            fi
        else
            app_ok=""
        fi

        printf "| %-10s | %-18s | %-10s | %-12s | %-18s %s\n" \
            "$group" "$label" "$in_repo" "$on_machine" "$status" "$app_ok"
    done

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
    local app_drift=0 config_drift=0 dock_drift=0

    echo "mac-setup plan (read-only)"
    echo "Compares this machine to packages and configs defined in the repo."
    echo ""

    plan_print_apps || app_drift=$?
    plan_print_configs || config_drift=$?
    plan_print_dock || dock_drift=$?

    echo "Legend:"
    echo "  Applications: installed = present on this Mac; not installed = setup would install"
    echo "  Configuration: applied = ~/Library/Preferences matches repo; not applied = repo has a plist but machine differs or is missing"
    echo "  Dock: run setup with --include-dock to apply"
    echo ""

    if (( app_drift == 0 && config_drift == 0 && dock_drift == 0 )); then
        echo "✅ Plan: machine matches desired apps, configs, and Dock."
        exit 0
    fi

    echo "⚠️  Plan: drift detected. Run setup to install missing apps or apply configs:"
    echo "    bash scripts/setup.sh"
    echo "    bash scripts/setup.sh --apps-only          # apps + preference restores"
    echo "    bash scripts/setup.sh --os-only --skip display --skip widget --include-dock   # Dock only"
    exit 1
}

main "$@"
