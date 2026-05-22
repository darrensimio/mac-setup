#!/usr/bin/env bash
# Orchestrate mac-setup scripts in a safe, documented order.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.bash
source "$SCRIPT_DIR/lib/common.bash"
mac_setup_init_paths

CHECK_ONLY=false
DRY_RUN=false
RUN_APPS=true
RUN_OS=true
INCLUDE_DOCK=false
SKIP_LIST=()

usage() {
    cat <<EOF
Usage: bash scripts/setup.sh [OPTIONS]

Run mac-setup application and OS configuration scripts from the repo root.

Options:
  --check           Validate prerequisites only (same as validate-env.bash)
  --apps-only       Run application install scripts only
  --os-only         Run OS configuration scripts only
  --skip NAME       Skip a script group (repeatable):
                    office, devtools, terminal, utils, display, widget, dock
  --include-dock    Run setup-dock.bash (resets Dock layout; use on a fresh Mac)
  --dry-run         Print scripts that would run without executing
  -h, --help        Show this help

Environment:
  MAC_SETUP_APPLY_DOCK=1   Same as --include-dock

Examples:
  bash scripts/setup.sh --check
  bash scripts/setup.sh --include-dock
  bash scripts/setup.sh --apps-only
  bash scripts/setup.sh --skip office --skip dock

Install Homebrew and Xcode CLI before running (see README.md).
EOF
}

should_skip() {
    (( ${#SKIP_LIST[@]} )) || return 1
    local name="$1"
    local s
    for s in "${SKIP_LIST[@]}"; do
        [[ "$s" == "$name" ]] && return 0
    done
    return 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check)
                CHECK_ONLY=true
                ;;
            --apps-only)
                RUN_APPS=true
                RUN_OS=false
                ;;
            --os-only)
                RUN_APPS=false
                RUN_OS=true
                ;;
            --skip)
                shift
                [[ $# -eq 0 ]] && { echo "error: --skip requires a name"; exit 1; }
                SKIP_LIST+=("$1")
                ;;
            --include-dock)
                INCLUDE_DOCK=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                echo "error: unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done

    if [[ "${MAC_SETUP_APPLY_DOCK:-}" == "1" ]]; then
        INCLUDE_DOCK=true
    fi
}

run_script() {
    local rel="$1"
    if $DRY_RUN; then
        echo "[dry-run] bash $SCRIPTS_DIR/$rel"
        return 0
    fi
    log_step "Running $rel"
    bash "$SCRIPTS_DIR/$rel"
}

run_applications() {
    local scripts=(
        "applications/setup-office-productivity.bash:office"
        "applications/setup-devtools.bash:devtools"
        "applications/setup-terminal.bash:terminal"
        "applications/setup-utils.bash:utils"
    )
    local entry rel skip_name
    for entry in "${scripts[@]}"; do
        rel="${entry%%:*}"
        skip_name="${entry##*:}"
        if should_skip "$skip_name"; then
            echo "Skipping $rel (--skip $skip_name)"
            continue
        fi
        run_script "$rel"
    done
}

run_os() {
    local scripts=(
        "os/setup-display.bash:display"
        "os/setup-widget.bash:widget"
        "os/setup-dock.bash:dock"
    )
    local entry rel skip_name
    for entry in "${scripts[@]}"; do
        rel="${entry%%:*}"
        skip_name="${entry##*:}"
        if should_skip "$skip_name"; then
            echo "Skipping $rel (--skip $skip_name)"
            continue
        fi
        if [[ "$skip_name" == "dock" ]] && ! $INCLUDE_DOCK; then
            echo "Skipping $rel (pass --include-dock or MAC_SETUP_APPLY_DOCK=1 to reset Dock)"
            continue
        fi
        run_script "$rel"
    done
}

main() {
    parse_args "$@"

    if $CHECK_ONLY; then
        exec bash "$SCRIPTS_DIR/validate-env.bash"
    fi

    log_step "Validating environment"
    if $DRY_RUN; then
        echo "[dry-run] bash $SCRIPTS_DIR/validate-env.bash"
    else
        bash "$SCRIPTS_DIR/validate-env.bash"
    fi

    if $RUN_APPS; then
        log_step "Application installs"
        run_applications
    fi

    if $RUN_OS; then
        log_step "OS configuration"
        run_os
    fi

    echo ""
    echo "✅ mac-setup finished."
}

main "$@"
