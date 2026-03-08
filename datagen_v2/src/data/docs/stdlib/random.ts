import { Doc } from "../../../lib";

export const random = new Doc("Randomness")
    .function("random", "n", "number", "Returns a random number between 0 and n.", [["`n`", "number", "Upper bound (Optional)"]])
    .function("random_range", "min, max", "number", "Returns a random number between min and max.", [["`min`", "number", "Lower bound"], ["`max`", "number", "Upper bound"]])
    .function("irandom", "n", "number", "Returns a random integer between 0 and n.", [["`n`", "number", "Upper bound (Optional)"]])
    .function("irandom_range", "min, max", "number", "Returns a random integer between min and max.", [["`min`", "number", "Lower bound"], ["`max`", "number", "Upper bound"]])
    .function("chance", "prob", "boolean", "Returns true with a probability of p (0-1).", [["`prob`", "number", "Probability"]])
    .function("choose", "values", "any", "Randomly chooses one of the provided values.", [["`values`", "any", "Values to choose from"]])
    .toString();
