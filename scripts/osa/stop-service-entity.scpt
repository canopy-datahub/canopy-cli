tell application "iTerm2"
  tell current window
    tell current session
      write text "cd $DATAHUB_HOME"
      write text "stopdatahubentity"
    end tell
  end tell
end tell