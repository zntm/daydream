import { ScriptFunction } from "./lib/ScriptFunction";

export const stringFunctions = [
    new ScriptFunction(
        "string",
        "Converts any value to its string representation.",
        "string",
        [{ name: "val", type: "any", description: "Value to convert" }]
    ).setExample('string(123); // "123"'),

    new ScriptFunction(
        "real",
        "Converts a string to a number.",
        "number",
        [{ name: "val", type: "string", description: "String containing a number" }]
    ).setExample('real("42"); // 42'),

    new ScriptFunction(
        "string_length",
        "Returns the length of a string.",
        "number",
        [{ name: "str", type: "string", description: "Input string" }]
    ).setExample('string_length("Hello"); // 5'),

    new ScriptFunction(
        "string_pos",
        "Finds the position of a substring within a string.",
        "number",
        [
            { name: "substr", type: "string", description: "Substring to find" },
            { name: "str", type: "string", description: "String to search in" }
        ]
    ).setExample('string_pos("lo", "Hello"); // 4'),

    new ScriptFunction(
        "string_delete",
        "Removes a part of a string.",
        "string",
        [
            { name: "str", type: "string", description: "Input string" },
            { name: "index", type: "number", description: "Start position (1-indexed)" },
            { name: "count", type: "number", description: "Number of characters to delete" }
        ]
    ).setExample('string_delete("Hello World", 6, 6); // "Hello"'),

    new ScriptFunction(
        "string_insert",
        "Inserts a substring into a string.",
        "string",
        [
            { name: "str", type: "string", description: "Base string" },
            { name: "substr", type: "string", description: "String to insert" },
            { name: "index", type: "number", description: "Insertion position (1-indexed)" }
        ]
    ).setExample('string_insert("World", "Hello ", 1); // "Hello World"'),

    new ScriptFunction(
        "string_replace",
        "Replaces the first occurrence of a substring.",
        "string",
        [
            { name: "str", type: "string", description: "Original string" },
            { name: "old", type: "string", description: "Substring to replace" },
            { name: "new", type: "string", description: "Replacement text" }
        ]
    ).setExample('string_replace("Hello World", "World", "Daydream"); // "Hello Daydream"'),

     new ScriptFunction(
        "string_replace_all",
        "Replaces all occurrences of a substring.",
        "string",
         [
            { name: "str", type: "string", description: "Original string" },
            { name: "old", type: "string", description: "Substring to replace" },
            { name: "new", type: "string", description: "Replacement text" }
        ]
    ).setExample('string_replace_all("ho ho ho", "ho", "he"); // "he he he"'),

    new ScriptFunction(
        "string_upper",
        "Converts a string to uppercase.",
        "string",
        [{ name: "str", type: "string", description: "Input string" }]
    ).setExample('string_upper("hello"); // "HELLO"'),

    new ScriptFunction(
        "string_lower",
        "Converts a string to lowercase.",
        "string",
        [{ name: "str", type: "string", description: "Input string" }]
    ).setExample('string_lower("HELLO"); // "hello"'),

     new ScriptFunction(
        "string_width",
        "Returns the width of the string in pixels based on current font.",
        "number",
        [{ name: "str", type: "string", description: "Input string" }]
    ),

     new ScriptFunction(
        "string_height",
        "Returns the height of the string in pixels based on current font.",
        "number",
        [{ name: "str", type: "string", description: "Input string" }]
    ),

    new ScriptFunction(
        "chr",
        "Converts an ASCII/Unicode value to a character.",
        "string",
        [{ name: "code", type: "number", description: "Character code" }]
    ).setExample('chr(65); // "A"'),

    new ScriptFunction(
        "ord",
        "Converts a character to its ASCII/Unicode value.",
        "number",
        [{ name: "char", type: "string", description: "Single character" }]
    ).setExample('ord("A"); // 65'),
];

export const typeFunctions = [
    new ScriptFunction("is_string", "Returns true if the value is a string.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_real", "Returns true if the value is a number.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_numeric", "Returns true if the value is numeric (real or int64).", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_bool", "Returns true if the value is a boolean.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_array", "Returns true if the value is an array.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_struct", "Returns true if the value is a struct.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_undefined", "Returns true if the value is undefined.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("is_regex", "Returns true if the value is a regex object.", "boolean", [{ name: "val", type: "any", description: "Value to check" }]),
    new ScriptFunction("typeof", "Returns a string describing the type of the value.", "string", [{ name: "val", type: "any", description: "Value to check" }])
        .setExample('typeof 123; // "number"'),
];

export const mathFunctions = [
    new ScriptFunction("floor", "Rounds down to the nearest integer.", "number", [{ name: "n", type: "number", description: "Value to round down"}]).setExample('floor(3.9); // 3'),
    new ScriptFunction("ceil", "Rounds up to the nearest integer.", "number", [{ name: "n", type: "number", description: "Value to round up"}]).setExample('ceil(3.1); // 4'),
    new ScriptFunction("round", "Rounds to the nearest integer.", "number", [{ name: "n", type: "number", description: "Value to round"}]).setExample('round(3.6); // 4'),
    new ScriptFunction("abs", "Returns the absolute value.", "number", [{ name: "n", type: "number", description: "Input value"}]).setExample('abs(-5); // 5'),
    new ScriptFunction("sign", "Returns the sign of a number.", "number", [{ name: "n", type: "number", description: "Input value"}]).setExample('sign(-50); // -1'),
    new ScriptFunction("min", "Returns the smaller of two values.", "number", [{ name: "a", type: "number", description: "First value"}, { name: "b", type: "number", description: "Second value"}]).setExample('min(10, 5); // 5'),
    new ScriptFunction("max", "Returns the larger of two values.", "number", [{ name: "a", type: "number", description: "First value"}, { name: "b", type: "number", description: "Second value"}]).setExample('max(10, 5); // 10'),
    new ScriptFunction("clamp", "Constrains a value between min and max.", "number", [{ name: "val", type: "number", description: "Value to constrain"}, { name: "min", type: "number", description: "Minimum bound"}, { name: "max", type: "number", description: "Maximum bound"}]).setExample('clamp(15, 0, 10); // 10'),
    new ScriptFunction("lerp", "Linearly interpolates between two values.", "number", [{ name: "a", type: "number", description: "Start value"}, { name: "b", type: "number", description: "End value"}, { name: "t", type: "number", description: "Interpolation factor (0-1)"}]).setExample('lerp(0, 100, 0.5); // 50'),
    new ScriptFunction("power", "Returns base raised to the power of exp.", "number", [{ name: "base", type: "number", description: "The base"}, { name: "exp", type: "number", description: "The exponent"}]).setExample('power(2, 3); // 8'),
    new ScriptFunction("sqrt", "Returns the square root.", "number", [{ name: "n", type: "number", description: "Value (must be >= 0)"}]).setExample('sqrt(16); // 4'),
    new ScriptFunction("sqr", "Returns the square of a number.", "number", [{ name: "n", type: "number", description: "Value to square"}]).setExample('sqr(5); // 25'),
    new ScriptFunction("frac", "Returns the fractional part of a number.", "number", [{ name: "n", type: "number", description: "Input value"}]).setExample('frac(3.75); // 0.75'),
    new ScriptFunction("sin", "Returns sine of x in radians.", "number", [{ name: "x", type: "number", description: "Angle in radians"}]),
    new ScriptFunction("cos", "Returns cosine of x in radians.", "number", [{ name: "x", type: "number", description: "Angle in radians"}]),
    new ScriptFunction("tan", "Returns tangent of x in radians.", "number", [{ name: "x", type: "number", description: "Angle in radians"}]),
    new ScriptFunction("dsin", "Returns sine of x in degrees.", "number", [{ name: "x", type: "number", description: "Angle in degrees"}]),
    new ScriptFunction("dcos", "Returns cosine of x in degrees.", "number", [{ name: "x", type: "number", description: "Angle in degrees"}]),
    new ScriptFunction("dtan", "Returns tangent of x in degrees.", "number", [{ name: "x", type: "number", description: "Angle in degrees"}]),
    new ScriptFunction("degtorad", "Converts degrees to radians.", "number", [{ name: "deg", type: "number", description: "Degrees"}]),
    new ScriptFunction("radtodeg", "Converts radians to degrees.", "number", [{ name: "rad", type: "number", description: "Radians"}]),
    new ScriptFunction("lengthdir_x", "Returns the horizontal component of a vector.", "number", [{ name: "len", type: "number", description: "Vector length"}, { name: "dir", type: "number", description: "Direction in degrees"}]),
    new ScriptFunction("lengthdir_y", "Returns the vertical component of a vector.", "number", [{ name: "len", type: "number", description: "Vector length"}, { name: "dir", type: "number", description: "Direction in degrees"}]),
    new ScriptFunction("point_distance", "Returns the distance between two points.", "number", [{ name: "x1", type: "number", description: "X of point 1"}, { name: "y1", type: "number", description: "Y of point 1"}, { name: "x2", type: "number", description: "X of point 2"}, { name: "y2", type: "number", description: "Y of point 2"}]),
    new ScriptFunction("point_direction", "Returns the direction from point 1 to point 2.", "number", [{ name: "x1", type: "number", description: "X of point 1"}, { name: "y1", type: "number", description: "Y of point 1"}, { name: "x2", type: "number", description: "X of point 2"}, { name: "y2", type: "number", description: "Y of point 2"}]),
    new ScriptFunction("exp", "Returns e^n.", "number", [{ name: "n", type: "number", description: "Exponent"}]),
    new ScriptFunction("ln", "Returns the natural logarithm function of x.", "number", [{ name: "x", type: "number", description: "Input value"}]),
    new ScriptFunction("log2", "Returns the base-2 logarithm.", "number", [{ name: "n", type: "number", description: "Input value"}]),
    new ScriptFunction("log10", "Returns the base-10 logarithm.", "number", [{ name: "n", type: "number", description: "Input value"}]),
    new ScriptFunction("arcsin", "Returns the arcsine in radians.", "number", [{ name: "x", type: "number", description: "Input value"}]),
    new ScriptFunction("arccos", "Returns the arccosine in radians.", "number", [{ name: "x", type: "number", description: "Input value"}]),
    new ScriptFunction("arctan", "Returns the arctangent in radians.", "number", [{ name: "x", type: "number", description: "Input value"}]),
    new ScriptFunction("arctan2", "Returns the angle from origin to (x, y) in radians.", "number", [{ name: "y", type: "number", description: "Y coordinate"}, { name: "x", type: "number", description: "X coordinate"}])
];

export const randomFunctions = [
    new ScriptFunction("random", "Returns a random floating-point number between 0 and x.", "number", [{ name: "x", type: "number", description: "Upper bound"}]),
    new ScriptFunction("irandom", "Returns a random integer between 0 and x.", "number", [{ name: "x", type: "number", description: "Upper bound"}]),
    new ScriptFunction("random_range", "Returns a random floating-point number between x1 and x2.", "number", [{ name: "x1", type: "number", description: "Lower bound"}, { name: "x2", type: "number", description: "Upper bound"}]),
    new ScriptFunction("irandom_range", "Returns a random integer between x1 and x2.", "number", [{ name: "x1", type: "number", description: "Lower bound"}, { name: "x2", type: "number", description: "Upper bound"}]),
    new ScriptFunction("choose", "Returns a random element from an array.", "any", [{ name: "array", type: "array", description: "Array to choose from"}]),
    new ScriptFunction("chance", "Returns true with the given probability (0-1).", "boolean", [{ name: "probability", type: "number", description: "Probability (0.0 to 1.0)"}])
];

export const dataStructureFunctions = [
    new ScriptFunction("array_length", "Returns the length of an array.", "number", [{ name: "array", type: "array", description: "Input array"}]),
    new ScriptFunction("array_push", "Adds elements to the end of an array.", "void", [{ name: "array", type: "array", description: "Target array"}, { name: "val", type: "any", description: "Value(s) to push", optional: true }]),
    new ScriptFunction("array_pop", "Removes and returns the last element of an array.", "any", [{ name: "array", type: "array", description: "Target array"}]),
    new ScriptFunction("array_resize", "Resizes an array.", "void", [{ name: "array", type: "array", description: "Target array"}, { name: "new_size", type: "number", description: "New size"}]),
    new ScriptFunction("array_copy", "Copies part of an array into another.", "void", [{ name: "dest", type: "array", description: "Destination array"}, { name: "dest_index", type: "number", description: "Start index in destination"}, { name: "src", type: "array", description: "Source array"}, { name: "src_index", type: "number", description: "Start index in source"}, { name: "length", type: "number", description: "Number of elements to copy"}]),
    new ScriptFunction("struct_get_names", "Returns an array of property names in a struct.", "array", [{ name: "struct", type: "struct", description: "Input struct"}]),
    new ScriptFunction("struct_get", "Gets a variable from a struct.", "any", [{ name: "struct", type: "struct", description: "Input struct"}, { name: "name", type: "string", description: "Variable name"}]),
    new ScriptFunction("struct_set", "Sets a variable in a struct.", "void", [{ name: "struct", type: "struct", description: "Input struct"}, { name: "name", type: "string", description: "Variable name"}, { name: "val", type: "any", description: "Value to set"}]),
    new ScriptFunction("struct_names_count", "Returns the number of variables in a struct.", "number", [{ name: "struct", type: "struct", description: "Input struct"}]),
    new ScriptFunction("struct_stringify", "Converts a struct/array to a JSON string.", "string", [{ name: "val", type: "any", description: "Value to stringify"}]),
    new ScriptFunction("struct_parse", "Parses a JSON string into a struct/array.", "any", [{ name: "json", type: "string", description: "JSON string"}]),
];

export const gameFunctions = [
    new ScriptFunction("tile_get", "Gets the tile ID at the specified position.", "Tile?", [{ name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }, { name: "z", type: "number", description: "Z position (layer)" }]),
    new ScriptFunction("tile_place", "Places a tile at the specified position.", "void", [{ name: "tile_id", type: "any", description: "Tile ID or name" }, { name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }, { name: "z", type: "number", description: "Z position (layer)" }]),
    new ScriptFunction("spawn_particle", "Spawns a particle at the specified position.", "void", [{ name: "particle", type: "string", description: "Particle name" }, { name: "x", type: "number", description: "X position in tiles" }, { name: "y", type: "number", description: "Y position in tiles" }]),
    new ScriptFunction("tag_get", "Gets tag data.", "any", [{ name: "tag_name", type: "string", description: "Name of the tag (without #)" }]),
];

export const systemFunctions = [
    new ScriptFunction("print", "Prints values to the debug console.", "void", [{ name: "values", type: "any", description: "Values to print", optional: true }]).setExample('print("Hello", 123);'),
    new ScriptFunction("event_emit", "Emits an event.", "void", [{ name: "event_type", type: "string", description: "Type of event" }, { name: "data", type: "struct", description: "Event data", optional: true }]),
    new ScriptFunction("event_subscribe", "Subscribes to an event.", "number", [{ name: "event_type", type: "string", description: "Type of event" }, { name: "callback", type: "function", description: "Callback function" }]),
    new ScriptFunction("event_unsubscribe", "Unsubscribes from an event.", "void", [{ name: "listener_id", type: "number", description: "ID returned by event_subscribe" }]),
    new ScriptFunction("time_start", "Starts a timer.", "void", [{ name: "name", type: "string", description: "Timer name" }]),
    new ScriptFunction("time_end", "Ends a timer and returns elapsed milliseconds.", "number", [{ name: "name", type: "string", description: "Timer name" }]),
    new ScriptFunction("runtime_error", "Throws a runtime error.", "void", [{ name: "type", type: "string", description: "Error type" }, { name: "message", type: "string", description: "Error message" }]),
    new ScriptFunction("assert", "Throws an error if the condition is false.", "void", [{ name: "condition", type: "boolean", description: "Condition to check" }, { name: "message", type: "string", description: "Error message", optional: true }]),
];

export const regexFunctions = [
    new ScriptFunction("regex_parse", "Creates a regex object.", "regex", [{ name: "pattern", type: "string", description: "Regex pattern" }, { name: "flags", type: "string", description: "Regex flags (e.g. 'g', 'i')", optional: true }]),
    new ScriptFunction("regex_test", "Tests if a string matches the regex.", "boolean", [{ name: "str", type: "string", description: "String to test" }, { name: "regex", type: "regex", description: "Regex object" }]),
    new ScriptFunction("regex_match", "Returns matches of the regex in the string.", "array", [{ name: "str", type: "string", description: "String to match" }, { name: "regex", type: "regex", description: "Regex object" }]),
    new ScriptFunction("regex_match_index", "Returns the index of the match.", "number", [{ name: "str", type: "string", description: "String to match" }, { name: "regex", type: "regex", description: "Regex object" }]),
    new ScriptFunction("regex_replace", "Replaces a match.", "string", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }, { name: "replacement", type: "string", description: "Replacement string" }]),
    new ScriptFunction("regex_replace_all", "Replaces all matches.", "string", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }, { name: "replacement", type: "string", description: "Replacement string" }]),
    new ScriptFunction("regex_split", "Splits a string by the regex.", "array", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }]),
];

export const renderFunctions = [
    new ScriptFunction("render_rectangle", "Draws a rectangle.", "void", [{ name: "x1", type: "number", description: "Left" }, { name: "y1", type: "number", description: "Top" }, { name: "x2", type: "number", description: "Right" }, { name: "y2", type: "number", description: "Bottom" }, { name: "outline", type: "boolean", description: "Draw outline only", optional: true }]),
    new ScriptFunction("render_circle", "Draws a circle.", "void", [{ name: "x", type: "number", description: "Center X" }, { name: "y", type: "number", description: "Center Y" }, { name: "r", type: "number", description: "Radius" }, { name: "outline", type: "boolean", description: "Draw outline only", optional: true }]),
    new ScriptFunction("render_text", "Draws text.", "void", [{ name: "text", type: "string", description: "Text to draw" }, { name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }]),
    new ScriptFunction("render_sprite", "Draws a sprite.", "void", [{ name: "sprite", type: "string", description: "Sprite name" }, { name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }, { name: "frame", type: "number", description: "Frame index", optional: true }]),
];

export const testFunctions = [
    new ScriptFunction("test", "Registers a test case.", "void", [{ name: "name", type: "string", description: "Test name" }, { name: "fn", type: "function", description: "Test function" }, { name: "stop_on_fail", type: "boolean", description: "Stop remaining tests if this fails", optional: true }]),
    new ScriptFunction("test_group", "Registers a group of tests.", "void", [{ name: "name", type: "string", description: "Group name" }, { name: "tests", type: "array", description: "Array of tests" }]),
    new ScriptFunction("test_expect", "Asserts that a value equals the expected value.", "boolean", [{ name: "actual", type: "any", description: "Actual value" }, { name: "expected", type: "any", description: "Expected value" }]),
];

export const allScriptFunctions = [
    ...stringFunctions,
    ...typeFunctions,
    ...mathFunctions,
    ...randomFunctions,
    ...dataStructureFunctions,
    ...gameFunctions,
    ...systemFunctions,
    ...regexFunctions,
    ...renderFunctions,
    ...testFunctions
];
