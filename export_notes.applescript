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
		set usedFileNames to {}
		
		-- Loop through each note
		repeat with aNote in notesList
			try
				-- Get note title and content
				set noteTitle to name of aNote
				set noteContent to body of aNote
				
				-- Clean illegal characters from title
				set cleanTitle to my cleanFileName(noteTitle)
				
				-- Generate unique file name
				set fileName to my generateUniqueFileName(cleanTitle, usedFileNames)
				set filePathPosix to exportFolderPosix & fileName
				
				-- Add to used file names list
				set end of usedFileNames to fileName

				-- Write content to file using AppleScript file I/O (UTF-8) to bypass shell arg length limits
				my writeTextToFile(noteContent, filePathPosix)
				
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

-- Generate unique file name with auto-increment suffix for duplicates
on generateUniqueFileName(cleanTitle, usedFileNames)
	set baseFileName to cleanTitle & ".html"
	
	-- Check if base file name is already used
	set isUsed to false
	repeat with i from 1 to count of usedFileNames
		if item i of usedFileNames = baseFileName then
			set isUsed to true
			exit repeat
		end if
	end repeat
	
	-- If not used, return base file name
	if not isUsed then
		return baseFileName
	end if
	
	-- If used, find the next available index
	set fileIndex to 2
	repeat
		set indexedFileName to cleanTitle & "--" & fileIndex & ".html"
		set isUsed to false
		
		repeat with i from 1 to count of usedFileNames
			if item i of usedFileNames = indexedFileName then
				set isUsed to true
				exit repeat
			end if
		end repeat
		
		if not isUsed then
			return indexedFileName
		end if
		
		set fileIndex to fileIndex + 1
	end repeat
end generateUniqueFileName

-- Write text to a file at POSIX path as UTF-8, replacing existing contents
on writeTextToFile(theText, posixPath)
	set f to open for access (POSIX file posixPath) with write permission
	try
		set eof of f to 0
		write theText as Çclass utf8È to f starting at 0
	on error errMsg number errNum
		try
			close access f
		end try
		error errMsg number errNum
	end try
	close access f
end writeTextToFile