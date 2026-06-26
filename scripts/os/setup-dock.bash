#!/usr/bin/env bash
set -euo pipefail

MODE="apply"
if [[ "${1:-}" == "--check" ]]; then
    MODE="check"
elif [[ -n "${1:-}" ]]; then
    echo "usage: bash scripts/os/setup-dock.bash [--check]" >&2
    exit 2
fi

desired_dock_apps=(
    "/Applications/Safari.app"
    "/Applications/Google Chrome.app"
    "/Applications/Microsoft Edge.app"
    "/Applications/ChatGPT.app"
    "/Applications/Poe.app"
    "/Applications/Spotify.app"
    "/System/Applications/Mail.app"
    "/Applications/Proton Mail.app"
    "/System/Applications/Messages.app"
    "/Applications/WhatsApp.app"
    "/Applications/Telegram.app"
    "/Applications/Post-it®.app"
    "/Applications/Notion.app"
    "/Applications/Microsoft Word.app"
    "/Applications/Microsoft Excel.app"
    "/Applications/Microsoft PowerPoint.app"
    "/Applications/Jabra Direct.app"
    "/System/Applications/App Store.app"
    "/System/Applications/System Settings.app"
    "/Applications/Proton Pass.app"
    "/Applications/1Password.app"
    "/Applications/Windows App.app"
    "/Applications/iTerm.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Cursor.app"
)

get_current_dock_apps() {
    python3 <<'PY'
import plistlib
import subprocess
import urllib.parse

try:
    raw = subprocess.check_output(["defaults", "export", "com.apple.dock", "-"], stderr=subprocess.DEVNULL)
except Exception:
    raise SystemExit(0)

try:
    data = plistlib.loads(raw)
except Exception:
    raise SystemExit(0)

apps = []
for item in data.get("persistent-apps", []) or []:
    td = (item or {}).get("tile-data", {}) or {}
    fd = td.get("file-data", {}) or {}
    path = fd.get("_CFURLString")
    if not isinstance(path, str):
        continue
    if path.startswith("file://"):
        # e.g. file:///Applications/Safari.app/
        parsed = urllib.parse.urlparse(path)
        path = urllib.parse.unquote(parsed.path)
    if path.endswith("/"):
        path = path[:-1]
    if path.endswith(".app"):
        apps.append(path)

print("\n".join(apps))
PY
}

if [[ "$MODE" == "check" ]]; then
    current=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && current+=("$line")
    done < <(get_current_dock_apps)

    ok=true
    if (( ${#current[@]} == 0 )); then
        echo "Dock check: could not read current Dock persistent-apps." >&2
        exit 2
    fi

    if (( ${#current[@]} != ${#desired_dock_apps[@]} )); then
        ok=false
        echo "Dock check: count differs (current=${#current[@]} desired=${#desired_dock_apps[@]})"
    fi

    for i in "${!desired_dock_apps[@]}"; do
        want="${desired_dock_apps[$i]}"
        got="${current[$i]:-}"
        if [[ "$want" != "$got" ]]; then
            ok=false
            printf 'Dock check: mismatch at position %d\n  desired: %s\n  current: %s\n' "$((i+1))" "$want" "${got:-<missing>}"
        fi
    done

    if $ok; then
        echo "✅ Dock check passed (apps + order match desired)."
        exit 0
    fi

    echo ""
    echo "To apply the desired Dock layout:"
    echo "  bash scripts/setup.sh --os-only --skip display --skip widget --include-dock"
    exit 1
fi

add_app_to_dock() {
    local app_path="$1"
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${app_path}</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
}

# Clear the Dock
# Removes all default apps to start with a blank slate
defaults write com.apple.dock persistent-apps -array ""

for app in "${desired_dock_apps[@]}"; do
    add_app_to_dock "$app"
done

# Set static Dock size to smallest (24)
defaults write com.apple.dock tilesize -int 24

# Enable Magnification
defaults write com.apple.dock magnification -bool true

# Set Hover (Large) size to 96
defaults write com.apple.dock largesize -int 96

# Disable 'Recents' for a cleaner look
defaults write com.apple.dock show-recents -bool false

# Configure Hot Corners
echo "⚙️  Configuring Hot Corner: Bottom-Left to Lock Screen..."

# Set screen to lock immediately after sleep or screen saver begins
echo "🔐 Setting lock screen timeout to: Immediately..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Set the Action
defaults write com.apple.dock wvous-bl-corner -int 13
# Set the Modifier (0 = None)
defaults write com.apple.dock wvous-bl-modifier -int 0

# Set the Action
defaults write com.apple.dock wvous-br-corner -int 13
# Set the Modifier (0 = None)
defaults write com.apple.dock wvous-br-modifier -int 0

# Restart Dock to apply everything
killall cfprefsd
killall Dock

echo "Dock reset complete."