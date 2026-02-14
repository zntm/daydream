import { readdirSync } from "fs";
import { join } from "path";
import { DatagenReturnData } from "../../../lib";

export default new DatagenReturnData(
    "crafting_recipes.json",
    readdirSync(join(__dirname, "./recipes"))
        .filter(file => file.endsWith(".ts"))
        .flatMap(
            (file) =>
                require(join(__dirname, "./recipes", file))
                    .default,
        )
        .flat(Infinity)
        .filter((recipe) => recipe !== undefined && recipe !== null),
);
