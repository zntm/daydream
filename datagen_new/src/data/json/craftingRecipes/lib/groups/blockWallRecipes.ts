import CraftingIngredientAmount from "../../registries/craftingIngredientAmount";
import CraftingRecipeAmount from "../../registries/craftingRecipeAmount";
import { CraftingIngredient } from "../CraftingIngredient";
import { CraftingRecipe } from "../CraftingRecipe";

export default (block: string, workbench: string | string[]) => [
    new CraftingRecipe(block, 1)
        .setCraftingStations(workbench)
        .setIngredients([
            new CraftingIngredient(
                `${block}_wall`,
                CraftingIngredientAmount.Wall,
            ),
        ]),
    new CraftingRecipe(`${block}_wall`, CraftingRecipeAmount.Wall)
        .setCraftingStations(workbench)
        .setIngredients([new CraftingIngredient(block, 1)]),
];
