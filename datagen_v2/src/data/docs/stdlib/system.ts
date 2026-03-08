import { Doc } from "../../../lib";

export const system = new Doc("System & Environment")
    .function("print", "values", "void", "Prints values to the debug console.", [["`values`", "any", "Values to print (Optional)"]], 'print("Hello", 123);')
    .function("event_emit", "event_type, data", "void", "Emits an event.", [["`event_type`", "string", "Type of event"], ["`data`", "struct", "Event data (Optional)"]])
    .function("event_subscribe", "event_type, callback", "number", "Subscribes to an event.", [["`event_type`", "string", "Type of event"], ["`callback`", "function", "Callback function"]])
    .function("event_unsubscribe", "listener_id", "void", "Unsubscribes from an event.", [["`listener_id`", "number", "ID returned by event_subscribe"]])
    .function("time_start", "name", "void", "Starts a timer.", [["`name`", "string", "Timer name"]])
    .function("time_end", "name", "number", "Ends a timer and returns elapsed milliseconds.", [["`name`", "string", "Timer name"]])
    .function("runtime_error", "type, message", "void", "Throws a runtime error.", [["`type`", "string", "Error type"], ["`message`", "string", "Error message"]])
    .function("assert", "condition, message", "void", "Throws an error if the condition is false.", [["`condition`", "boolean", "Condition to check"], ["`message`", "string", "Error message (Optional)"]])
    .toString();
