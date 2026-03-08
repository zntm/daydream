import { Doc } from "../../../lib";

export const regex = new Doc("Regular Expressions")
    .function("regex_create", "pattern, flags", "Regex", "Creates a regex object.", [["`pattern`", "string", "Regex pattern"], ["`flags`", "string", "Regex flags (e.g. \"gi\") (Optional)"]])
    .function("regex_test", "regex, str", "boolean", "Checks if a pattern matches a string.", [["`regex`", "Regex", "Regex object"], ["`str`", "string", "String to test"]])
    .function("regex_match", "regex, str", "array", "Returns an array of matches.", [["`regex`", "Regex", "Regex object"], ["`str`", "string", "String to match"]])
    .function("regex_replace", "regex, str, new", "string", "Replaces matches with new text.", [["`regex`", "Regex", "Regex object"], ["`str`", "string", "Original string"], ["`new`", "string", "Replacement text"]])
    .toString();
