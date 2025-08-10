-- ==============================================================================
-- Notes Export Script
-- Purpose: Export notes from Apple Notes to HTML files with extracted images
-- ==============================================================================

-- Constants
property DEFAULT_EXPORT_FOLDER_NAME : "Notes Export/"
property IMAGES_SUBFOLDER_NAME : "images/"
property FILE_EXTENSION : ".html"
property FILENAME_SEPARATOR : "--"

-- Main entry point
on run argv
	try
		-- Validate and parse command line arguments
		set parsedArgs to my parseCommandLineArguments(argv)
		if parsedArgs is missing value then return
		
		set folderNameToExport to item 1 of parsedArgs
		set exportDirectoryPath to item 2 of parsedArgs
		
		-- Setup export environment
		my setupExportDirectories(exportDirectoryPath)
		
		-- Execute the export process
		my executeNotesExport(folderNameToExport, exportDirectoryPath)
		
	on error errorMessage
		my showErrorDialog("Export failed: " & errorMessage)
	end try
end run

-- Parse and validate command line arguments
on parseCommandLineArguments(argv)
	if (count of argv) < 1 then
		display dialog "Usage: osascript export_notes.applescript \"folder_name\" [\"output_directory\"]" buttons {"OK"}
		return missing value
	end if
	
	set folderName to item 1 of argv
	set exportPath to my determineExportPath(argv)
	
	if exportPath is missing value then return missing value
	
	return {folderName, exportPath}
end parseCommandLineArguments

-- Determine the export path from arguments or use default
on determineExportPath(argv)
	if (count of argv) >= 2 then
		set outputDirectory to item 2 of argv
		if outputDirectory starts with "/" then
			return outputDirectory & "/" & DEFAULT_EXPORT_FOLDER_NAME
		else
			my showErrorDialog("Please provide an absolute POSIX output directory (starting with '/') or omit it to use Desktop.")
			return missing value
		end if
	else
		return (POSIX path of (path to desktop)) & DEFAULT_EXPORT_FOLDER_NAME
	end if
end determineExportPath

-- Execute the main export process
on executeNotesExport(folderName, exportPath)
	tell application "Notes"
		activate
		
		set targetFolder to my findNotesFolder(folderName)
		if targetFolder is missing value then
			my showErrorDialog("Folder \"" & folderName & "\" not found")
			return
		end if
		
		set exportedNotesCount to my exportAllNotesFromFolder(notes of targetFolder, exportPath)
		display dialog "Successfully exported " & exportedNotesCount & " notes to " & exportPath buttons {"OK"}
	end tell
end executeNotesExport

-- Create necessary directories
on setupExportDirectories(exportFolderPosix)
	try
		do shell script "mkdir -p " & quoted form of exportFolderPosix
		do shell script "mkdir -p " & quoted form of (exportFolderPosix & IMAGES_SUBFOLDER_NAME)
	end try
end setupExportDirectories

-- Find specified folder by name
on findNotesFolder(folderName)
	tell application "Notes"
		repeat with aFolder in folders
			if name of aFolder is folderName then return aFolder
		end repeat
	end tell
	return missing value
end findNotesFolder

-- Export all notes in the given folder
on exportAllNotesFromFolder(notesList, exportFolderPosix)
	set exportCount to 0
	set usedFileNames to {}
	
	repeat with aNote in notesList
		try
			tell application "Notes"
				set noteTitle to name of aNote
				set noteContent to body of aNote
			end tell
			
			-- Generate unique file name
			set fileName to my generateUniqueHtmlFileName(my sanitizeFileName(noteTitle), usedFileNames)
			set end of usedFileNames to fileName
			
			-- Process images and write to file
			set processedContent to my processImages(noteContent, exportFolderPosix)
			my writeTextToFile(processedContent, exportFolderPosix & fileName)
			
			set exportCount to exportCount + 1
		on error errMsg
			log "Error exporting note \"" & noteTitle & "\": " & errMsg
		end try
	end repeat
	
	return exportCount
end exportAllNotesFromFolder

-- Clean illegal characters from file name
on sanitizeFileName(fileName)
	set illegalChars to {"/", ":", "?", "<", ">", "\\", "*", "|", "\""}
	set cleanName to fileName
	
	repeat with illegalChar in illegalChars
		set cleanName to my replaceText(cleanName, illegalChar, "_")
	end repeat
	
	return cleanName
end sanitizeFileName

-- Generate unique html file name with auto-increment suffix for duplicates
on generateUniqueHtmlFileName(cleanTitle, usedFileNames)
	set baseFileName to cleanTitle & FILE_EXTENSION
	
	-- Check if base file name is already used
	if baseFileName is not in usedFileNames then return baseFileName
	
	-- If used, find the next available index
	set fileIndex to 2
	repeat
		set indexedFileName to cleanTitle & FILENAME_SEPARATOR & fileIndex & FILE_EXTENSION
		if indexedFileName is not in usedFileNames then return indexedFileName
		set fileIndex to fileIndex + 1
	end repeat
end generateUniqueHtmlFileName

-- Process images in HTML content: extract base64 images and replace with relative paths
on processImages(htmlContent, exportFolderPosix)
	set modifiedContent to htmlContent
	
	repeat
		-- Find base64 image patterns
		set imgStart to my findText(modifiedContent, "src=\"data:image/")
		if imgStart is 0 then exit repeat
		
		set imgEnd to my findTextFromPos(modifiedContent, "\"", imgStart + 5)
		if imgEnd is 0 then exit repeat
		
		-- Extract data URL
		set dataURL to text (imgStart + 5) thru (imgEnd - 1) of modifiedContent
		set {imageFormat, base64Data} to my parseDataURL(dataURL)
		
		if imageFormat is not "" and base64Data is not "" then
			-- Generate stable filename and save image
			set imageHash to my generateHash(base64Data)
			set imageFileName to "img_" & imageHash & "." & imageFormat
			set imageFilePath to exportFolderPosix & IMAGES_SUBFOLDER_NAME & imageFileName
			
			my saveImageIfNotExists(base64Data, imageFilePath)
			
			-- Replace with relative path
			set oldTag to text imgStart thru imgEnd of modifiedContent
			set newTag to "src=\"" & IMAGES_SUBFOLDER_NAME & imageFileName & "\""
			set modifiedContent to my replaceText(modifiedContent, oldTag, newTag)
		else
			exit repeat
		end if
	end repeat
	
	return modifiedContent
end processImages

-- Find text position
on findText(theText, searchString)
	return my findTextFromPos(theText, searchString, 1)
end findText

on findTextFromPos(theText, searchString, startPos)
	try
		set AppleScript's text item delimiters to searchString
		set textItems to text items of (text startPos thru -1 of theText)
		set AppleScript's text item delimiters to ""
		
		if (count of textItems) > 1 then
			return startPos + (length of (item 1 of textItems))
		else
			return 0
		end if
	on error
		set AppleScript's text item delimiters to ""
		return 0
	end try
end findTextFromPos

-- Parse data URL to extract format and base64 data
on parseDataURL(dataURL)
	try
		if dataURL starts with "data:image/" then
			set semicolonPos to my findText(dataURL, ";")
			set base64Pos to my findText(dataURL, "base64,")
			
			if semicolonPos > 0 and base64Pos > 0 then
				set imageFormat to text 12 thru (semicolonPos - 1) of dataURL
				set base64Data to text (base64Pos + 7) thru -1 of dataURL
				return {imageFormat, base64Data}
			end if
		end if
	end try
	return {"", ""}
end parseDataURL

-- Generate content hash for stable filename
on generateHash(base64Data)
	try
		-- Use temporary file to avoid command line argument length issues
		set tempFile to "/tmp/base64_data_" & (random number from 1000 to 9999) & ".txt"
		my writeTextToFile(base64Data, tempFile)
		
		set pythonScript to "import hashlib; data=open('" & tempFile & "').read(); print(hashlib.md5(data.encode()).hexdigest()[:8])"
		set shellCommand to "python3 -c \"" & pythonScript & "\""
		set imageHash to do shell script shellCommand
		
		-- Clean up temporary file
		try
			do shell script "rm " & quoted form of tempFile
		end try
		
		return imageHash
	on error
		return "img" & (length of base64Data)
	end try
end generateHash

-- Save image if it doesn't exist
on saveImageIfNotExists(base64Data, imageFilePath)
	try
		do shell script "test -f " & quoted form of imageFilePath
	on error
		-- File doesn't exist, save image
		my saveImage(base64Data, imageFilePath)
	end try
end saveImageIfNotExists

-- Dialog helpers
on showErrorDialog(messageText)
	display dialog messageText buttons {"OK"}
end showErrorDialog

-- Save base64 image
on saveImage(base64Data, imageFilePath)
	try
		-- Use temporary file to avoid command line argument length issues
		set tempFile to "/tmp/base64_data_" & (random number from 1000 to 9999) & ".txt"
		my writeTextToFile(base64Data, tempFile)
		
		set pythonScript to "import base64; data=open('" & tempFile & "').read(); decoded=base64.b64decode(data); open('" & imageFilePath & "','wb').write(decoded)"
		set shellCommand to "python3 -c \"" & pythonScript & "\""
		do shell script shellCommand
		
		-- Clean up temporary file
		try
			do shell script "rm " & quoted form of tempFile
		end try
		
	on error errMsg
		log "Error saving image: " & errMsg
	end try
end saveImage

-- Replace text in string
on replaceText(theText, searchString, replacementString)
	set AppleScript's text item delimiters to searchString
	set textItems to text items of theText
	set AppleScript's text item delimiters to replacementString
	set newText to textItems as string
	set AppleScript's text item delimiters to ""
	return newText
end replaceText

-- Write text to a file at POSIX path as UTF-8, replacing existing contents
on writeTextToFile(theText, posixPath)
	set f to open for access (POSIX file posixPath) with write permission
	try
		set eof of f to 0
		-- Write as UTF-8 (using AppleScript's 'utf8' class)
		write theText as Çclass utf8È to f starting at 0
	on error errMsg number errNum
		try
			close access f
		end try
		error errMsg number errNum
	end try
	close access f
end writeTextToFile