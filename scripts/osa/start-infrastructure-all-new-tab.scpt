tell application "iTerm2"
  tell current window
    set newTab to (create tab with default profile)
    tell current session of newTab
      write text "cd $CANOPY_HOME"
--      write text "startcanopyinfra"
      write text "echo 'Please start PostgreSQL, Opensearch and Keycloak manually!'"
    end tell
  end tell
end tell