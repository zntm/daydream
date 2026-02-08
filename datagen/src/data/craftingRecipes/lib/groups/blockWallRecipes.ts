import {
    CraftingIngredient,
    CraftingRecipe,
    IngredientAmount,
    RecipeAmount,
} from "../Recipe";

export default (
    rawMaterial: string,
    block: string,
    blockAmount: number = 1,
    wall: string,
    workbench: string | string[],
) => [
        new CraftingRecipe(block, blockAmount)
            .setCraftingStations(workbench)
            .setIngredients(new CraftingIngredient(rawMaterial)),
        new CraftingRecipe(wall, RecipeAmount.Wall)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(block, IngredientAmount.Wall),
            ),
    ];
