on run argv
	-- Get command line parameters: folder name and optional output directory
	if (count of argv) < 1 then
		display dialog "Usage: osascript export_notes.applescript \"folder_name\" [\"output_directory\"]" buttons {"OK"}
		return
	end if
	
	set folderName to item 1 of argv
	
	-- Set export directory
	if (count of argv) >= 2 then
		-- Use specified output directory
		set outputDir to item 2 of argv
		set exportFolder to outputDir & "Notes Export:"
	else
		-- Default to desktop
		set exportFolder to (path to desktop as string) & "Notes Export:"
	end if
	
	-- Create export directory
	try
		do shell script "mkdir -p " & quoted form of POSIX path of exportFolder
	end try
	
	-- Connect to Notes app
	tell application "Notes"
		activate
		
		-- Find the specified folder
		set targetFolder to missing value
		repeat with aFolder in folders
			if name of aFolder is folderName then
				set targetFolder to aFolder
				exit repeat
			end if
		end repeat
		
		-- If folder not found, show error
		if targetFolder is missing value then
			display dialog "Folder \"" & folderName & "\" not found" buttons {"OK"}
			return
		end if
		
		-- Get all notes in the folder
		set notesList to notes of targetFolder
		set exportCount to 0
		
		-- Loop through each note
		repeat with aNote in notesList
			try
				-- Get note title and content
				set noteTitle to name of aNote
				set noteContent to body of aNote
				
				-- Generate 6-digit random number
				set randomNumber to my generateRandomNumber()
				
				-- Clean illegal characters from title
				set cleanTitle to my cleanFileName(noteTitle)
				
				-- Generate file name
				set fileName to cleanTitle & "-" & randomNumber & ".txt"
				set filePath to exportFolder & fileName
				
				-- Export as plain text file
				set fileHandle to open for access file filePath with write permission
				write noteContent to fileHandle
				close access fileHandle
				
				set exportCount to exportCount + 1
				
			on error errMsg
				-- If error, close file handle and continue
				try
					close access file filePath
				end try
				log "Error exporting note \"" & noteTitle & "\": " & errMsg
			end try
		end repeat
		
		-- Show completion message
		display dialog "Successfully exported " & exportCount & " notes to \"Notes Export\" folder on desktop" buttons {"OK"}
	end tell
end run

-- Function to generate 6-digit random number
on generateRandomNumber()
	set randomNum to ""
	repeat 6 times
		set randomNum to randomNum & (random number from 0 to 9)
	end repeat
	return randomNum
end generateRandomNumber

-- Clean illegal characters from file name
on cleanFileName(fileName)
	set illegalChars to {"/", ":", "?", "<", ">", "\\", "*", "|", "\""}
	set cleanName to fileName
	
	repeat with illegalChar in illegalChars
		set AppleScript's text item delimiters to illegalChar
		set textItems to text items of cleanName
		set AppleScript's text item delimiters to "_"
		set cleanName to textItems as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	return cleanName
end cleanFileName