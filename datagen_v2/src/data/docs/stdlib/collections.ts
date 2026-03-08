import { Doc } from "../../../lib";

export const collections = new Doc("Data Structures")
    .function("array_length", "array", "number", "Returns the length of an array.", [["`array`", "array", "Input array"]])
    .function("array_push", "array, val", "void", "Adds elements to the end of an array.", [["`array`", "array", "Target array"], ["`val`", "any", "Value(s) to push (Optional)"]])
    .function("array_pop", "array", "any", "Removes and returns the last element of an array.", [["`array`", "array", "Target array"]])
    .function("array_resize", "array, new_size", "void", "Resizes an array.", [["`array`", "array", "Target array"], ["`new_size`", "number", "New size"]])
    .function("array_copy", "dest, dest_index, src, src_index, length", "void", "Copies part of an array into another.", [["`dest`", "array", "Destination array"], ["`dest_index`", "number", "Start index in destination"], ["`src`", "array", "Source array"], ["`src_index`", "number", "Start index in source"], ["`length`", "number", "Number of elements to copy"]])
    .function("struct_get_names", "struct", "array", "Returns an array of property names in a struct.", [["`struct`", "struct", "Input struct"]])
    .function("struct_names_count", "struct", "number", "Returns the number of variables in a struct.", [["`struct`", "struct", "Input struct"]])
    .function("struct_stringify", "val", "string", "Converts a struct/array to a JSON string.", [["`val`", "any", "Value to stringify"]])
    .function("struct_parse", "json", "any", "Parses a JSON string into a struct/array.", [["`json`", "string", "JSON string"]])
    .toString();
