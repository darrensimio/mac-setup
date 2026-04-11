# Clear all active widgets from the desktop
# Note: This removes them from the active list, effectively "deleting" them from view.
echo "🗑️  Removing all active desktop widgets..."
defaults delete com.apple.widgets active-widgets 2>/dev/null

# Restart the Widget and Window Manager processes to apply changes
killall Chronod
killall WindowManager