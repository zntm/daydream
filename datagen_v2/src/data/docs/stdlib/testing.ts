import { Doc } from "../../../lib";

export const testing = new Doc("Testing")
    .function("test_group", "name, tests", "void", "Defines a new group of tests.", [["`name`", "string", "Name of the group"], ["`tests`", "array", "Array of test cases"]])
    .function("test", "name, callback", "void", "Defines a test case within a group.", [["`name`", "string", "Name of the test"], ["`callback`", "function", "Test logic"]])
    .function("test_expect", "actual, expected", "void", "Asserts that two values are equal.", [["`actual`", "any", "The value to test"], ["`expected`", "any", "The expected value"]])
    .function("assert", "condition, [message]", "void", "Throws an error if the condition is false.", [["`condition`", "boolean", "Condition to check"], ["`message`", "string", "Optional failure message"]])
    .toString();
