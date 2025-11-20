import {
    CraftingIngredient,
    CraftingRecipe,
    IngredientAmount,
} from "../craftingRecipes";

export default (
    material: string,
    block: string,
    workbench: string | string[],
) => {
    return [
        new CraftingRecipe(block)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    material,
                    IngredientAmount.MaterialCompact,
                ),
            ),
        new CraftingRecipe(material, IngredientAmount.MaterialCompact)
            .setCraftingStations(workbench)
            .setIngredients(new CraftingIngredient(block)),
    ];
};
