#!/bin/bash

# This script uses AppleScript to automate the UI interaction 
# since there is no direct CLI command for scaling in macOS Tahoe.

osascript <<EOD
tell application "System Settings"
    activate
    reveal anchor "displaysDisplay" show pane id "com.apple.Displays-Settings.extension"
end tell

delay 1

tell application "System Events"
    tell process "System Settings"
        -- This clicks the "More Space" icon, which is usually the last button in the scaling group
        -- In Tahoe, these are identified as radio buttons or buttons in a list
        set scalingButtons to radio buttons of radio group 1 of group 1 of scroll area 1 of group 1 of group 2 of window 1
        click last item of scalingButtons
    end tell
end tell

-- Optional: Quit System Settings after applying
delay 0.5
quit application "System Settings"
EOD

echo "Display set to More Space!"