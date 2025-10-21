import {
    CraftingIngredient,
    CraftingRecipe,
    IngredientAmount,
    RecipeAmount,
} from "../craftingRecipes";

export default (
    rawMaterial: string,
    block: string,
    blockAmount: number = 1,
    wall: string,
    workbench: string | string[],
) => {
    return [
        new CraftingRecipe(block, blockAmount)
            .setCraftingStations(workbench)
            .setIngredients(new CraftingIngredient(rawMaterial)),
        new CraftingRecipe(wall, RecipeAmount.Wall)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(block, IngredientAmount.Wall),
            ),
    ];
};
