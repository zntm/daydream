import { readdirSync } from "fs";
import { join } from "path";
import { DatagenReturnData } from "../../../lib";

export default new DatagenReturnData(
    "crafting_recipes.json",
    readdirSync(join(__dirname, "./craftingRecipes"))
        .map(
            (file) =>
                import.meta.require(join(__dirname, "./craftingRecipes", file))
                    .default,
        )
        .flat(Infinity)
        .filter((recipe) => recipe !== undefined && recipe !== null),
);
