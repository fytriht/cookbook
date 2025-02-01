tell application "Notes"
   set targetFolder to folder "食谱"
   -- set targetFolder to folder "tes1"
   repeat with theNote in notes of targetFolder
      set noteId to id of theNote

      ---- Create content
      set noteProperties to { ¬
         {label: "id", value: noteId}, ¬
         {label: "name", value: name of theNote}, ¬
         {label: "body", value: body of theNote}, ¬
         {label: "creation date", value: creation date of theNote}, ¬
         {label: "modification date", value: modification date of theNote} ¬
      }
      set outputContent to ""
      repeat with p in noteProperties
         set outputContent to outputContent & "<=" & (label of p) & "=>" & return & (value of p) & return & "<=/=>" & return
      end repeat
      
      ---- Write to file

      -- Gen file name
      -- example of noteId: x-coredata://15D6970F-7586-491D-AFDC-195EE5FF239F/ICNote/p2844
      set start to (offset of "ICNote/" in noteId) + 7 
      set fileName to name of theNote & "-" & (text start thru -1 of noteId)

      set scriptPath to POSIX path of (path to me)
      set scriptFolder to do shell script "dirname " & quoted form of scriptPath
      set filePath to scriptFolder & "/output/" & fileName
      set fileRef to open for access filePath with write permission
      try
         write outputContent to fileRef as «class utf8»
         close access fileRef
      on error
         close access fileRef
      end try
   end repeat
end tell