tell application "Notes"
   set targetFolder to folder "È£üË∞±"
   -- set targetFolder to folder "tes1"
   repeat with theNote in notes of targetFolder
      set noteId to id of theNote

      ---- Create content
      set outputContent to ""
      set outputContent to outputContent & "<=id=>\n" & noteId & "\n<=/=>\n"
      set outputContent to outputContent & "<=name=>\n" & name of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=body=>\n" & body of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=creation date=>\n" & creation date of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=modification date=>\n" & modification date of theNote & "\n<=/=>\n"
      
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
         write outputContent to fileRef as ¬´class utf8¬ª
         close access fileRef
      on error
         close access fileRef
      end try
   end repeat
end tell