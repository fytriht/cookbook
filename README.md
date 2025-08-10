# Apple Notes Exporter

A powerful AppleScript tool for exporting notes from Apple Notes app to HTML files with automatic image extraction and processing.

## Key Features

- 📝 Export all notes from a specific folder in Apple Notes
- 🌐 Save as HTML format, preserving complete note formatting and styling
- 🖼️ **Smart Image Processing**: Automatically extract and save images as separate files
- 📁 Auto-create structured export directories (note files + images subfolder)
- 🔄 Intelligent duplicate filename handling (using --2, --3 suffixes)
- 🛡️ Safe filename processing with automatic illegal character cleanup
- 📍 Support for custom export directories
- ⚡ Content-hash based image deduplication to avoid saving identical images

## Usage

### Basic Usage (Export to Desktop)
```bash
osascript export_notes.applescript "folder_name"
```

### Custom Export Directory
```bash
osascript export_notes.applescript "folder_name" "/absolute/path/to/export/directory"
```

## Examples

Export "Work Notes" folder to desktop:
```bash
osascript export_notes.applescript "Work Notes"
```

Export "Personal Notes" folder to Documents directory:
```bash
osascript export_notes.applescript "Personal Notes" "/Users/username/Documents"
```

## Parameters

- `folder_name` (required): Name of the folder in Apple Notes to export
- `output_directory` (optional): Absolute path to custom export directory. If not specified, exports to desktop

## Export Output

### Directory Structure
```
Notes Export/              # Main export folder
├── Note Title 1.html      # Note HTML files
├── Note Title 2--2.html   # Duplicate names get auto-suffixes
├── Note Title 3.html
└── images/               # Images subfolder
    ├── img_a1b2c3d4.png  # Content-hash based image filenames
    ├── img_e5f6g7h8.jpg
    └── img_i9j0k1l2.gif
```

### File Characteristics
- Each note is saved as a separate HTML file
- Filename format: `{note_title}.html` or `{note_title}--{number}.html` (for duplicates)
- Images are named using first 8 characters of MD5 hash for stable, unique filenames
- HTML image references are automatically updated to relative paths

## System Requirements

- macOS operating system
- Apple Notes application
- Python 3 (for image processing and hash calculation)
- AppleScript support (built into macOS)

## Project Files

```
cookbook/
├── export_notes.applescript    # Main export script
├── README.md                  # Project documentation
└── .gitignore                # Git ignore configuration
```

## Error Handling

- ✅ Parameter validation: Checks for required folder name parameter
- ✅ Folder existence check: Verifies specified Notes folder exists
- ✅ Individual note error isolation: Failed note export doesn't affect others
- ✅ File access error handling: Automatically handles file permissions and path issues
- ✅ Image processing error recovery: Uses fallback naming when image extraction fails

## Technical Features

### Image Processing Workflow
1. 🔍 Scan HTML content for base64-encoded images
2. 🧮 Calculate MD5 hash of image content
3. 💾 Decode base64 data and save as separate image files
4. 🔗 Update HTML image references to relative paths
5. ♻️ Automatic deduplication of identical images

### Filename Processing
- Illegal character replacement: `/`, `:`, `?`, `<`, `>`, `\`, `*`, `|`, `"` → `_`
- Duplicate name handling: Automatically adds `--2`, `--3` numeric suffixes
- Encoding support: Full UTF-8 support for proper handling of international characters

## Important Notes

- 🔄 Script will activate the Notes app during export
- 📂 Export directory must use absolute paths (starting with `/`)
- 🖼️ Supports common image formats: PNG, JPG, GIF, etc.
- 🔒 Image files are named based on content hash, preventing duplicate saves
- ⚡ Uses temporary files for large base64 data to avoid command line argument length limits