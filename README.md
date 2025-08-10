# Apple Notes Exporter

A simple AppleScript to export notes from Apple Notes app to plain text files.

## Features

- Export all notes from a specific folder in Apple Notes
- Save as plain text format (.txt)
- Automatic filename generation: `{original_title}-{random_6_digits}.txt`
- Handle duplicate note titles with random suffixes
- Support for custom output directory
- Clean illegal characters from filenames

## Usage

### Basic Usage (Export to Desktop)
```bash
osascript export_notes.applescript "folder_name"
```

### Custom Output Directory
```bash
osascript export_notes.applescript "folder_name" "/path/to/output/directory"
```

## Examples

Export notes from "Work Notes" folder to desktop:
```bash
osascript export_notes.applescript "Work Notes"
```

Export notes from "Personal" folder to Documents:
```bash
osascript export_notes.applescript "Personal" "~/Documents/"
```

## Parameters

- `folder_name` (required): The name of the folder in Apple Notes to export
- `output_directory` (optional): Custom output directory path. If not specified, exports to desktop

## Output

- Creates a "Notes Export" folder in the specified directory (or desktop by default)
- Each note is saved as a separate `.txt` file
- Filename format: `{note_title}-{6_digit_random_number}.txt`
- Shows completion dialog with export count

## Requirements

- macOS with Apple Notes app
- AppleScript support (built into macOS)

## File Structure

```
export_notes.applescript    # Main export script
README.md                  # This documentation
```

## Error Handling

- Displays error message if folder name is not provided
- Shows error if specified folder doesn't exist in Notes
- Continues processing other notes if individual note export fails
- Automatically handles file access errors

## Notes

- The script will activate the Notes app during export
- Illegal filename characters (`/`, `:`, `?`, `<`, `>`, `\`, `*`, `|`, `"`) are replaced with underscores
- Random 6-digit suffix prevents filename conflicts for notes with identical titles