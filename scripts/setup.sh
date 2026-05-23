#!/usr/bin/env bash
# Orchestrate mac-setup scripts in a safe, documented order.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.bash
source "$SCRIPT_DIR/lib/common.bash"
mac_setup_init_paths

CHECK_ONLY=false
DRY_RUN=false
RUN_APPS=true
RUN_OS=true
INCLUDE_DOCK=false
FAIL_FAST=false
SKIP_LIST=()
SCRIPT_FAILURES=0

usage() {
    cat <<EOF
Usage: bash scripts/setup.sh [OPTIONS]

Run mac-setup application and OS configuration scripts from the repo root.

By default, install failures are logged and later steps still run. The process
exits with code 1 if any step failed.

Options:
  --check           Validate prerequisites only (same as validate-env.bash)
  --apps-only       Run application install scripts only
  --os-only         Run OS configuration scripts only
  --skip NAME       Skip a script group (repeatable):
                    office, devtools, terminal, utils, display, widget, dock
  --include-dock    Run setup-dock.bash (resets Dock layout; use on a fresh Mac)
  --fail-fast       Stop on the first failed script (old behavior)
  --dry-run         Print scripts that would run without executing
  -h, --help        Show this help

Environment:
  MAC_SETUP_APPLY_DOCK=1   Same as --include-dock

Examples:
  bash scripts/setup.sh --check
  bash scripts/setup.sh --include-dock
  bash scripts/setup.sh --fail-fast
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
            --fail-fast)
                FAIL_FAST=true
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
    local display_name="${2:-$rel}"
    if $DRY_RUN; then
        echo "[dry-run] bash $SCRIPTS_DIR/$rel"
        return 0
    fi
    log_step "Running $rel"
    local script_out script_status
    script_out=$(bash "$SCRIPTS_DIR/$rel" 2>&1) && script_status=0 || script_status=$?
    if [[ $script_status -eq 0 ]]; then
        mac_setup_report "completed" "$display_name"
        return 0
    fi
    echo "$script_out" >&2
    mac_setup_report_failed "$display_name" "$script_out" "bash $SCRIPTS_DIR/$rel"
    if $FAIL_FAST; then
        echo "❌ $rel failed. Stopping (--fail-fast)."
        exit 1
    fi
    echo "❌ $rel failed. Continuing with remaining steps."
    SCRIPT_FAILURES=$((SCRIPT_FAILURES + 1))
}

run_applications() {
    local scripts=(
        "applications/setup-office-productivity.bash|office|Office productivity"
        "applications/setup-devtools.bash|devtools|Developer tools"
        "applications/setup-terminal.bash|terminal|Terminal environment"
        "applications/setup-utils.bash|utils|Utilities"
    )
    local entry rel skip_name display_name
    for entry in "${scripts[@]}"; do
        IFS='|' read -r rel skip_name display_name <<<"$entry"
        if should_skip "$skip_name"; then
            echo "Skipping $rel (--skip $skip_name)"
            mac_setup_report "skipped" "$display_name"
            continue
        fi
        run_script "$rel" "$display_name"
    done
}

run_os() {
    local scripts=(
        "os/setup-display.bash|display|Display scaling"
        "os/setup-widget.bash|widget|Desktop widgets"
        "os/setup-dock.bash|dock|Dock layout"
    )
    local entry rel skip_name display_name
    for entry in "${scripts[@]}"; do
        IFS='|' read -r rel skip_name display_name <<<"$entry"
        if should_skip "$skip_name"; then
            echo "Skipping $rel (--skip $skip_name)"
            mac_setup_report "skipped" "$display_name"
            continue
        fi
        if [[ "$skip_name" == "dock" ]] && ! $INCLUDE_DOCK; then
            echo "Skipping $rel (pass --include-dock or MAC_SETUP_APPLY_DOCK=1 to reset Dock)"
            mac_setup_report "skipped" "$display_name"
            continue
        fi
        run_script "$rel" "$display_name"
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
        bash "$SCRIPTS_DIR/validate-env.bash" || exit 1
    fi

    if ! $DRY_RUN && ($RUN_APPS || $RUN_OS); then
        mac_setup_report_begin
        export MAC_SETUP_ORCHESTRATED=1
        mac_setup_acquire_sudo || exit 1
        trap mac_setup_release_sudo EXIT
    fi

    if $RUN_APPS; then
        log_step "Application installs"
        run_applications
    fi

    if $RUN_OS; then
        log_step "OS configuration"
        run_os
    fi

    if ! $DRY_RUN && ($RUN_APPS || $RUN_OS); then
        mac_setup_print_summary
    fi

    echo ""
    if (( SCRIPT_FAILURES > 0 )); then
        echo "⚠️  mac-setup finished with $SCRIPT_FAILURES failed script(s)."
        exit 1
    fi
    echo "✅ mac-setup finished."
}

main "$@"
