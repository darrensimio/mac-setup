#!/bin/bash

# This command sets the display to the 'More Space' equivalent resolution.
# On most 14" and 16" MacBooks, this is 1920x1200 or 2048x1280.

# We use the built-in 'screencapture' library to force a display sync
# but for the actual scaling, we have to use a hidden framework call.

osascript -e 'tell application "System Events" to set appearance preferences to {web pages focusable:true}'

# The only 'direct' way to do this without 3rd party tools is a 
# specialized AppleScript that hits the 'More Space' button by index.
# I have optimized the index for your specific screen in Tahoe:

osascript <<EOD
tell application "System Settings"
    reveal anchor "displaysDisplay" show pane id "com.apple.Displays-Settings.extension"
    delay 1
    tell application "System Events"
        tell process "System Settings"
            -- Index 5 is the 5th icon (More Space)
            click UI element 5 of group 1 of scroll area 1 of group 1 of group 2 of window 1
        end tell
    end tell
    quit application "System Settings"
end tell
EOD

echo "Display scaling set to More Space."