tell application "iTerm2"
  tell current window
    tell current session
      write text "cd $CANOPY_HOME"
      write text "stopdatahubdownload"
    end tell
  end tell
end tell