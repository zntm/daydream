import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const SystemDocs = new DocModule("System & Environment", "", [
    new DocFunction("print", "Prints values to the debug console.", [{ name: "values", type: "any", description: "Values to print (Optional)" }], "void", "print(\"Hello\", 123);"),
    new DocFunction("event_emit", "Emits an event.", [{ name: "event_type", type: "string", description: "Type of event" }, { name: "data", type: "struct", description: "Event data (Optional)" }], "void"),
    new DocFunction("event_subscribe", "Subscribes to an event.", [{ name: "event_type", type: "string", description: "Type of event" }, { name: "callback", type: "function", description: "Callback function" }], "number"),
    new DocFunction("event_unsubscribe", "Unsubscribes from an event.", [{ name: "listener_id", type: "number", description: "ID returned by event_subscribe" }], "void"),
    new DocFunction("time_start", "Starts a timer.", [{ name: "name", type: "string", description: "Timer name" }], "void"),
    new DocFunction("time_end", "Ends a timer and returns elapsed milliseconds.", [{ name: "name", type: "string", description: "Timer name" }], "number"),
    new DocFunction("runtime_error", "Throws a runtime error.", [{ name: "type", type: "string", description: "Error type" }, { name: "message", type: "string", description: "Error message" }], "void"),
    new DocFunction("assert", "Throws an error if the condition is false.", [{ name: "condition", type: "boolean", description: "Condition to check" }, { name: "message", type: "string", description: "Error message (Optional)" }], "void"),
]);

export default [
    new DatagenReturnData("system.md", SystemDocs.toMarkdown())
];
