import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const StringsDocs = new DocModule("Strings and Types", "", [
    new DocFunction("string", "Converts any value to its string representation.", [{ name: "val", type: "any", description: "Value to convert" }], "string", "string(123); // \"123\""),
    new DocFunction("real", "Converts a string to a number.", [{ name: "val", type: "string", description: "String containing a number" }], "number", "real(\"42\"); // 42"),
    new DocFunction("string_length", "Returns the length of a string.", [{ name: "str", type: "string", description: "Input string" }], "number", "string_length(\"Hello\"); // 5"),
    new DocFunction("string_pos", "Finds the position of a substring within a string.", [{ name: "substr", type: "string", description: "Substring to find" }, { name: "str", type: "string", description: "String to search in" }], "number", "string_pos(\"lo\", \"Hello\"); // 4"),
    new DocFunction("string_delete", "Removes a part of a string.", [{ name: "str", type: "string", description: "Input string" }, { name: "index", type: "number", description: "Start position (1-indexed)" }, { name: "count", type: "number", description: "Number of characters to delete" }], "string", "string_delete(\"Hello World\", 6, 6); // \"Hello\""),
    new DocFunction("string_insert", "Inserts a substring into a string.", [{ name: "str", type: "string", description: "Base string" }, { name: "substr", type: "string", description: "String to insert" }, { name: "index", type: "number", description: "Insertion position (1-indexed)" }], "string", "string_insert(\"World\", \"Hello \", 1); // \"Hello World\""),
    new DocFunction("string_replace", "Replaces the first occurrence of a substring.", [{ name: "str", type: "string", description: "Original string" }, { name: "old", type: "string", description: "Substring to replace" }, { name: "new", type: "string", description: "Replacement text" }], "string", "string_replace(\"Hello World\", \"World\", \"Daydream\"); // \"Hello Daydream\""),
    new DocFunction("string_replace_all", "Replaces all occurrences of a substring.", [{ name: "str", type: "string", description: "Original string" }, { name: "old", type: "string", description: "Substring to replace" }, { name: "new", type: "string", description: "Replacement text" }], "string", "string_replace_all(\"ho ho ho\", \"ho\", \"he\"); // \"he he he\""),
    new DocFunction("string_upper", "Converts a string to uppercase.", [{ name: "str", type: "string", description: "Input string" }], "string", "string_upper(\"hello\"); // \"HELLO\""),
    new DocFunction("string_lower", "Converts a string to lowercase.", [{ name: "str", type: "string", description: "Input string" }], "string", "string_lower(\"HELLO\"); // \"hello\""),
    new DocFunction("string_width", "Returns the width of the string in pixels based on current font.", [{ name: "str", type: "string", description: "Input string" }], "number"),
    new DocFunction("string_height", "Returns the height of the string in pixels based on current font.", [{ name: "str", type: "string", description: "Input string" }], "number"),
    new DocFunction("chr", "Converts an ASCII/Unicode value to a character.", [{ name: "code", type: "number", description: "Character code" }], "string", "chr(65); // \"A\""),
    new DocFunction("ord", "Converts a character to its ASCII/Unicode value.", [{ name: "char", type: "string", description: "Single character" }], "number", "ord(\"A\"); // 65"),
    new DocFunction("is_string", "Returns true if the value is a string.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_real", "Returns true if the value is a number.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_numeric", "Returns true if the value is numeric (real or int64).", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_bool", "Returns true if the value is a boolean.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_array", "Returns true if the value is an array.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_struct", "Returns true if the value is a struct.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_undefined", "Returns true if the value is undefined.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("is_regex", "Returns true if the value is a regex object.", [{ name: "val", type: "any", description: "Value to check" }], "boolean"),
    new DocFunction("typeof", "Returns a string describing the type of the value.", [{ name: "val", type: "any", description: "Value to check" }], "string", "typeof(123); // \"number\""),
]);

export default [
    new DatagenReturnData("strings.md", StringsDocs.toMarkdown())
];
