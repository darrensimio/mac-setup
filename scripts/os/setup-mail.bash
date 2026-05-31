#!/usr/bin/env bash
# Apple Mail preferences (com.apple.mail).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.bash"
mac_setup_init_paths

echo "📧 Configuring Mail.app..."

mail_prefs_plist="$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail.plist"

if [[ ! -f "$mail_prefs_plist" ]]; then
    echo "Opening Mail once to create its preferences (first-time setup)..."
    open -a Mail
    sleep 5
fi

osascript -e 'tell application "Mail" to quit' 2>/dev/null || true
sleep 1

# General → New message sound → None; uncheck Play sounds for other mail actions
mac_setup_mail_apply_sound_prefs

open -a Mail
sleep 2
mac_setup_mail_apply_sound_prefs_ui
osascript -e 'tell application "Mail" to quit' 2>/dev/null || true
sleep 1

# Re-apply after UI may have synced prefs
mac_setup_mail_apply_sound_prefs

sound_ok=false
play_ok=false
mac_setup_mail_new_message_sound_off && sound_ok=true
mac_setup_mail_play_sounds_off && play_ok=true

if $sound_ok; then
    echo "✅ New message sound: off (None)"
    mac_setup_report "completed" "Mail: new message sound off"
else
    current="$(defaults read -app Mail NewMessagesSoundName 2>/dev/null || echo "<unset>")"
    echo "⚠️  New message sound still: $current" >&2
    mac_setup_report "skipped" "Mail: new message sound off (verify manually)"
fi

if $play_ok; then
    echo "✅ Play sounds for other mail actions: off"
    mac_setup_report "completed" "Mail: other mail sounds off"
else
    play="$(defaults read -app Mail PlayMailSounds 2>/dev/null || echo "<unset>")"
    echo "⚠️  PlayMailSounds still: $play" >&2
    mac_setup_report "skipped" "Mail: other mail sounds off (verify manually)"
fi

if ! $sound_ok || ! $play_ok; then
    echo "" >&2
    echo "If settings did not stick:" >&2
    echo "  1. Grant Terminal (or iTerm) Accessibility + Full Disk Access in System Settings → Privacy & Security" >&2
    echo "  2. Quit Mail, re-run: bash scripts/os/setup-mail.bash" >&2
    echo "  3. Or set manually: Mail → Settings → General → New message sound → None;" >&2
    echo "     uncheck Play sounds for other mail actions" >&2
fi

mac_setup_finish "Mail setup"
