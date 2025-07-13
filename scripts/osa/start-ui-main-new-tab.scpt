tell application "iTerm2"
  tell current window
    set newTab to (create tab with default profile)
    tell current session of newTab
      write text "cd $DATAHUB_HOME/datahub-ui-main"
      write text "npm run dev & echo $! > ~/.datahub/pid-ui-main.txt"
    end tell
  end tell
end tell