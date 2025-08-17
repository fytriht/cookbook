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
- 📋 **Metadata Export**: Generate meta.json with note titles, IDs, and deep links for easy integration

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
├── meta.json             # Metadata file with note information
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
- **meta.json**: Contains metadata for all exported notes with titles and deep links

### Metadata File (meta.json)

The export process automatically generates a `meta.json` file containing metadata for all exported notes:

```json
{
  "x-coredata://15D6970F-7586-491D-AFDC-195EE5FF239F/ICNote/p4516": {
    "title": "Meeting Notes",
    "deeplink": "applenotes:note/15D6970F-7586-491D-AFDC-195EE5FF239F"
  },
  "x-coredata://A1B2C3D4-E5F6-G7H8-I9J0-K1L2M3N4O5P6/ICNote/p1234": {
    "title": "Project Ideas",
    "deeplink": "applenotes:note/A1B2C3D4-E5F6-G7H8-I9J0-K1L2M3N4O5P6"
  }
}
```

**Metadata Fields:**

- **Key**: Original note ID (x-coredata format)
- **title**: Note title as it appears in Apple Notes
- **deeplink**: Apple Notes deep link URL for direct access to the note

## System Requirements

- macOS operating system
- Apple Notes application
- Python 3 (for image processing and hash calculation)
- AppleScript support (built into macOS)
- **iTerm2 with Full Disk Access** (required for database access)

### Important: Grant Full Disk Access to iTerm2

To enable the script to access Apple Notes database for generating deep links, you must grant Full Disk Access permission to iTerm2:

1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Full Disk Access** from the left sidebar
3. Click the lock icon and enter your password to make changes
4. Click the **+** button and add **iTerm2** to the list
5. Ensure the checkbox next to iTerm2 is checked
6. Restart iTerm2 for the changes to take effect

**Note**: Without this permission, the script will still export notes successfully, but deep link generation may be limited due to database access restrictions.

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
