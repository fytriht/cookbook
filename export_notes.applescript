on run argv
	-- Get command line parameters: folder name and optional output directory
	if (count of argv) < 1 then
		display dialog "Usage: osascript export_notes.applescript \"folder_name\" [\"output_directory\"]" buttons {"OK"}
		return
	end if
	
	set folderName to item 1 of argv
	
	-- Set export directory (use POSIX paths)
	if (count of argv) >= 2 then
		set outputDir to item 2 of argv
		if outputDir starts with "/" then
			set exportFolderPosix to outputDir & "/Notes Export/"
		else
			display dialog "Please provide an absolute POSIX output directory (starting with '/') or omit it to use Desktop." buttons {"OK"}
			return
		end if
	else
		set exportFolderPosix to (POSIX path of (path to desktop)) & "Notes Export/"
	end if
	
	-- Create export directory
	try
		do shell script "mkdir -p " & quoted form of exportFolderPosix
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
				
				-- Generate stable hash of content
				set hashSuffix to my computeContentHash(noteContent)
				
				-- Clean illegal characters from title
				set cleanTitle to my cleanFileName(noteTitle)
				
				-- Generate file name
				set fileName to cleanTitle & "-" & hashSuffix & ".txt"
				set filePathPosix to exportFolderPosix & fileName
				
				-- Export as plain text file with UTF-8 encoding
				try
					do shell script "echo " & quoted form of noteContent & " > " & quoted form of filePathPosix
				on error
					-- Fallback method using printf for better UTF-8 handling
					do shell script "/usr/bin/printf %s " & quoted form of noteContent & " > " & quoted form of filePathPosix
				end try
				
				set exportCount to exportCount + 1
				
			on error errMsg
				-- If error, log and continue
				log "Error exporting note \"" & noteTitle & "\": " & errMsg
			end try
		end repeat
		
		-- Show completion message
		display dialog "Successfully exported " & exportCount & " notes to " & exportFolderPosix buttons {"OK"}
	end tell
end run

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

on computeContentHash(theText)
	set cmd to "/usr/bin/printf %s " & quoted form of theText & " | /usr/bin/shasum -a 256 | /usr/bin/awk '{print $1}'"
	set fullHash to do shell script cmd
	return text 1 thru 8 of fullHash
end computeContentHash