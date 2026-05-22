#!/usr/bin/env bash
# Validate prerequisites. Exit 0 if ready, 1 otherwise.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.bash
source "$SCRIPT_DIR/lib/common.bash"
mac_setup_init_paths

FAIL=0
WARN=0

check() {
    local label="$1"
    shift
    if "$@"; then
        echo "✔ $label"
    else
        echo "✘ $label"
        return 1
    fi
}

warn() {
    local label="$1"
    shift
    if "$@"; then
        echo "✔ $label"
    else
        echo "⚠ $label (optional or required for some scripts)"
        WARN=1
    fi
}

echo "Validating mac-setup environment..."
echo ""

if check "Xcode Command Line Tools" xcode-select -p &>/dev/null; then
    :
else
    FAIL=1
fi

if check "Homebrew" command -v brew &>/dev/null; then
    :
else
    FAIL=1
fi

warn "mas (Mac App Store CLI)" command -v mas &>/dev/null

if command -v mas &>/dev/null; then
    if mas account &>/dev/null; then
        echo "✔ mas App Store sign-in"
    else
        echo "⚠ mas App Store sign-in (run: mas signin your@appleid.com)"
        WARN=1
    fi
fi

echo ""
if [[ "$FAIL" -ne 0 ]]; then
    echo "Environment check failed. Install missing prerequisites (see README.md)."
    exit 1
fi

if [[ "$WARN" -ne 0 ]]; then
    echo "Environment OK with warnings. Some scripts may fail until warnings are resolved."
    exit 0
fi

echo "Environment OK."
exit 0
