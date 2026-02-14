import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const TestingDocs = new DocModule("Testing", "", [
    new DocFunction("test", "Registers a test case.", [
        { name: "name", type: "string", description: "Test name" },
        { name: "fn", type: "function", description: "Test function" },
        { name: "stop_on_fail", type: "boolean", description: "Stop remaining tests if this fails (Optional)" }
    ], "void"),
    new DocFunction("test_group", "Registers a group of tests.", [
        { name: "name", type: "string", description: "Group name" },
        { name: "tests", type: "array", description: "Array of tests" }
    ], "void"),
    new DocFunction("test_expect", "Asserts that a value equals the expected value.", [
        { name: "actual", type: "any", description: "Actual value" },
        { name: "expected", type: "any", description: "Expected value" }
    ], "boolean"),
]);

export default [
    new DatagenReturnData("testing.md", TestingDocs.toMarkdown())
];
