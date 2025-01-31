tell application "Notes"
   set targetFolder to folder "食谱"
   repeat with theNote in notes of targetFolder

      -- Create content
      set outputContent to ""
      set outputContent to outputContent & "<=id=>\n" & id of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=name=>\n" & name of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=body=>\n" & body of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=creation date=>\n" & creation date of theNote & "\n<=/=>\n"
      set outputContent to outputContent & "<=modification date=>\n" & modification date of theNote & "\n<=/=>\n"
      
      -- -- Write to file
      set fileName to name of theNote
      set scriptPath to POSIX path of (path to me)
      set scriptFolder to do shell script "dirname " & quoted form of scriptPath
      set filePath to scriptFolder & "/output/" & fileName
      do shell script "echo " & quoted form of outputContent & " > " & quoted form of filePath
   end repeat
end tell