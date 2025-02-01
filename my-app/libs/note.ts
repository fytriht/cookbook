import { readFileSync, readdirSync } from "fs";
import { join } from "path";

interface Note {
  id: string;
  name: string;
  body: string;
  creationDate: string;
  modificationDate: string;
}

export const _readFromDisk = (outputDir = join(process.cwd(), '../output')): string[] => {
    try {
        const files = readdirSync(outputDir);
        return files.map(file => readFileSync(join(outputDir, file), 'utf-8'));
    } catch(error) {
        console.error('Error reading files from disk:', error);
        return []
    }
}

export const _parseNote = (note: string): Note => {
    const parsedNote: Partial<Record<string, string>> = {};
    const sectionRegex = /<=([\w ]+)=>[\r\n]([\s\S]*?)[\r\n]<=\/=>/g;
    for (const [, label, value] of note.matchAll(sectionRegex)) {
        parsedNote[label] = value;
    }
    
    // Validate that all required fields are present
    const fields = ['id', 'name', 'body', 'creation date', 'modification date'];
    const missingFields = fields.filter(field => 
        !Object.hasOwn(parsedNote, field)
    );
    if (missingFields.length > 0) {
        console.error("note: ", note)
        throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
    }
    
    return parsedNote as unknown as Note
}

export const getAllNotes = (): Note[] => {
    const notes = _readFromDisk();
    return notes.map(note => _parseNote(note));
}
