tell application "iTerm2"
  tell current window
    tell current session
      write text "cd $CANOPY_HOME"
      write text "stopdatahubreport"
    end tell
  end tell
end tell