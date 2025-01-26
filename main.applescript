tell application "Notes"
   set targetFolder to folder "tes1"
   repeat with eachNote in notes of targetFolder
      set noteId to the id of eachNote
      set noteTitle to the name of eachNote
      set noteBody to the body of eachNote
      log "===="
      log noteBody
      log "===="
   end repeat
end tell