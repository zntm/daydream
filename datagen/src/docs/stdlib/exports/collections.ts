import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const CollectionsDocs = new DocModule("Data Structures", "", [
    new DocFunction("array_length", "Returns the length of an array.",
        [{ name: "array", type: "array", description: "Input array" }], "number"),
    new DocFunction("array_push", "Adds elements to the end of an array.",
        [{ name: "array", type: "array", description: "Target array" }, { name: "val", type: "any", description: "Value(s) to push (Optional)" }], "void"),
    new DocFunction("array_pop", "Removes and returns the last element of an array.",
        [{ name: "array", type: "array", description: "Target array" }], "any"),
    new DocFunction("array_resize", "Resizes an array.",
        [{ name: "array", type: "array", description: "Target array" }, { name: "new_size", type: "number", description: "New size" }], "void"),
    new DocFunction("array_copy", "Copies part of an array into another.",
        [
            { name: "dest", type: "array", description: "Destination array" },
            { name: "dest_index", type: "number", description: "Start index in destination" },
            { name: "src", type: "array", description: "Source array" },
            { name: "src_index", type: "number", description: "Start index in source" },
            { name: "length", type: "number", description: "Number of elements to copy" }
        ], "void"),
    new DocFunction("struct_get_names", "Returns an array of property names in a struct.",
        [{ name: "struct", type: "struct", description: "Input struct" }], "array"),
    new DocFunction("struct_names_count", "Returns the number of variables in a struct.",
        [{ name: "struct", type: "struct", description: "Input struct" }], "number"),
    new DocFunction("struct_stringify", "Converts a struct/array to a JSON string.",
        [{ name: "val", type: "any", description: "Value to stringify" }], "string"),
    new DocFunction("struct_parse", "Parses a JSON string into a struct/array.",
        [{ name: "json", type: "string", description: "JSON string" }], "any"),
]);

export default [
    new DatagenReturnData("collections.md", CollectionsDocs.toMarkdown())
];
