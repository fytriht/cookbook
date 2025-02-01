import { describe, expect, test } from 'vitest'
import { _parseNote } from './note';
import dedent from 'dedent';

describe('parseNote', () => {
    test('should parse valid note correctly', () => {
        const validNote = dedent`
            <=id=>
            123
            <=/=>
            <=name=>
            Test Note
            <=/=>
            <=body=>
            Test Body
            <=/=>
            <=creation date=>
            2023-11-20
            <=/=>
            <=modification date=>
            2023-11-21
            <=/=>`;

        const result = _parseNote(validNote);
        expect(result).toEqual({
            id: '123',
            name: 'Test Note',
            body: 'Test Body',
            'creation date': '2023-11-20',
            'modification date': '2023-11-21'
        });
    });

    test('should parse multiline body correctly', () => {
        const noteWithMultilineBody = dedent`
            <=id=>
            123
            <=/=>
            <=name=>
            Test
            <=/=>
            <=body=>
            Line 1
            Line 2
            Line 3
            <=/=>
            <=creation date=>
            2023-11-20
            <=/=>
            <=modification date=>
            2023-11-21
            <=/=>`;

        const result = _parseNote(noteWithMultilineBody);
        expect(result.body).toBe('Line 1\nLine 2\nLine 3');
    });

    test('should throw error when missing required field', () => {
        const invalidNote = dedent`
            <=id=>
            123
            <=/=>
            <=name=>
            Test Note
            <=/=>`;

        expect(() => _parseNote(invalidNote))
            .toThrowError('Missing required fields: body, creation date, modification date');
    });

    test('should handle empty values correctly', () => {
        const noteWithEmptyValues = dedent`
            <=id=>
            123
            <=/=>
            <=name=>
            name
            <=/=>
            <=body=>

            <=/=>
            <=creation date=>
            2023-11-20
            <=/=>
            <=modification date=>
            2023-11-21
            <=/=>`;

        const result = _parseNote(noteWithEmptyValues);
        expect(result.body).toBe('');
    });

    test('should handle HTML content in body', () => {
        const noteWithHtml = dedent`
            <=id=>
            123
            <=/=>
            <=name=>
            Test
            <=/=>
            <=body=>
            <div>Hello</div>
            <p>World</p>
            <=/=>
            <=creation date=>
            2023-11-20
            <=/=>
            <=modification date=>
            2023-11-21
            <=/=>`;

        const result = _parseNote(noteWithHtml);
        expect(result.body).toBe('<div>Hello</div>\n<p>World</p>');
    });

    test('should handle \\n \\r correctly', () => {
        const realNote = '<=id=>\rx-coredata://15D6970F-7586-491D-AFDC-195EE5FF239F/ICNote/p2844\r<=/=>\r<=name=>\rTips\r<=/=>\r<=body=>\r<div><h1>Tips</h1></div>\n<div><br></div>\n<div><h1><br></h1></div>\n<ol>\n<li>姜蒜的成熟度不同，爆香的时候先放姜，后放蒜<br></li>\n</ol>\n\r<=/=>\r<=creation date=>\rSaturday, November 4, 2023 at 17:00:10\r<=/=>\r<=modification date=>\rSaturday, November 4, 2023 at 17:00:36\r<=/=>\r';

        const result = _parseNote(realNote);
        expect(result).toEqual({
            id: 'x-coredata://15D6970F-7586-491D-AFDC-195EE5FF239F/ICNote/p2844',
            name: 'Tips',
            body: '<div><h1>Tips</h1></div>\n<div><br></div>\n<div><h1><br></h1></div>\n<ol>\n<li>姜蒜的成熟度不同，爆香的时候先放姜，后放蒜<br></li>\n</ol>\n',
            'creation date': 'Saturday, November 4, 2023 at 17:00:10',
            'modification date': 'Saturday, November 4, 2023 at 17:00:36'
        });
    });
});