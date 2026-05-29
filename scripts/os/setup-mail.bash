#!/usr/bin/env bash
# Apple Mail preferences (com.apple.mail).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths

echo "📧 Configuring Mail.app..."

mail_prefs_dir="$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences"
mail_prefs_plist="$mail_prefs_dir/com.apple.mail.plist"

# Mail must have run at least once so its sandbox preferences exist.
if [[ ! -f "$mail_prefs_plist" ]]; then
    echo "Opening Mail once to create its preferences (first-time setup)..."
    open -a Mail
    sleep 5
fi

osascript -e 'tell application "Mail" to quit' 2>/dev/null || true
sleep 1

# General → New message sound → None
# https://support.apple.com/guide/mail/change-general-settings-cpmlprefgen/mac
if defaults write -app Mail NewMessagesSoundName -string "None" 2>/dev/null; then
    current="$(defaults read -app Mail NewMessagesSoundName 2>/dev/null || true)"
    if [[ "$current" == "None" ]]; then
        echo "✅ New message sound set to None"
        mac_setup_report "completed" "Mail: new message sound off"
    else
        echo "⚠️  Wrote preference but read-back is: ${current:-<unset>}"
        mac_setup_report "completed" "Mail: new message sound off (verify in Mail → Settings → General)"
    fi
else
    echo "⚠️  Could not write Mail preferences automatically." >&2
    echo "    Set manually: Mail → Settings → General → New message sound → None" >&2
    echo "    Or grant Terminal Full Disk Access, quit Mail, and re-run this script." >&2
    mac_setup_report "skipped" "Mail: new message sound off (manual)"
fi

mac_setup_finish "Mail setup"
