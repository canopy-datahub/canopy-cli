tell application "iTerm2"
  tell current window
    set newTab to (create tab with default profile)
    tell current session of newTab
      write text "cd $CANOPY_HOME"
      write text "startcanopysubmission"
    end tell
  end tell
end tell