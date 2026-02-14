import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const RegexDocs = new DocModule("Regular Expressions", "", [
    new DocFunction("regex_parse", "Creates a regex object.", [{ name: "pattern", type: "string", description: "Regex pattern" }, { name: "flags", type: "string", description: "Regex flags (e.g. 'g', 'i') (Optional)" }], "regex"),
    new DocFunction("regex_test", "Tests if a string matches the regex.", [{ name: "str", type: "string", description: "String to test" }, { name: "regex", type: "regex", description: "Regex object" }], "boolean", "regex_test(\"hello\", /h/);"),
    new DocFunction("regex_match", "Returns matches of the regex in the string.", [{ name: "str", type: "string", description: "String to match" }, { name: "regex", type: "regex", description: "Regex object" }], "array", "regex_match(\"hello\", /l+/g);"),
    new DocFunction("regex_match_index", "Returns the index of the match.", [{ name: "str", type: "string", description: "String to match" }, { name: "regex", type: "regex", description: "Regex object" }], "number", "regex_match_index(\"hello\", /e/);"),
    new DocFunction("regex_replace", "Replaces a match.", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }, { name: "replacement", type: "string", description: "Replacement string" }], "string", "regex_replace(\"hello\", /l/, \"L\");"),
    new DocFunction("regex_replace_all", "Replaces all matches.", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }, { name: "replacement", type: "string", description: "Replacement string" }], "string", "regex_replace_all(\"ho ho ho\", /ho/, \"he\");"),
    new DocFunction("regex_split", "Splits a string by the regex.", [{ name: "str", type: "string", description: "Input string" }, { name: "regex", type: "regex", description: "Regex object" }], "array", "regex_split(\"a,b,c\", /,/);"),
]);

export default [
    new DatagenReturnData("regex.md", RegexDocs.toMarkdown())
];
