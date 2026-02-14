import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const RandomDocs = new DocModule("Random Functions", "", [
    new DocFunction("random", "Returns a random floating-point number between 0 and x.", [{ name: "x", type: "number", description: "Upper bound" }], "number"),
    new DocFunction("irandom", "Returns a random integer between 0 and x.", [{ name: "x", type: "number", description: "Upper bound" }], "number"),
    new DocFunction("random_range", "Returns a random floating-point number between x1 and x2.", [{ name: "x1", type: "number", description: "Lower bound" }, { name: "x2", type: "number", description: "Upper bound" }], "number"),
    new DocFunction("irandom_range", "Returns a random integer between x1 and x2.", [{ name: "x1", type: "number", description: "Lower bound" }, { name: "x2", type: "number", description: "Upper bound" }], "number"),
    new DocFunction("choose", "Returns a random element from an array.", [{ name: "array", type: "array", description: "Array to choose from" }], "any"),
    new DocFunction("chance", "Returns true with the given probability (0-1).", [{ name: "probability", type: "number", description: "Probability (0.0 to 1.0)" }], "boolean"),
]);

export default [
    new DatagenReturnData("random.md", RandomDocs.toMarkdown())
];
