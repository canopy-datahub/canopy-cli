tell application "iTerm2"
  tell current window
    set newTab to (create tab with default profile)
    tell current session of newTab
      write text "cd $DATAHUB_HOME"
      write text "startdatahubkk"
    end tell
  end tell
end tell