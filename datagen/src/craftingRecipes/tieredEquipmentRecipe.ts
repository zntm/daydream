import {
    CraftingIngredient,
    CraftingRecipe,
    IngredientAmount,
} from "../craftingRecipes";

import compactMaterialRecipe from "./compactMaterialRecipe";

export default (
    namespace: string,
    material: string,
    workbench: string | string[],
    furnace: string,
) => {
    return [
        new CraftingRecipe(`${namespace}:${material}_sword`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    IngredientAmount.Sword,
                ),
            ),
        new CraftingRecipe(`${namespace}:${material}_pickaxe`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    IngredientAmount.Pickaxe,
                ),
            ),
        new CraftingRecipe(`${namespace}:${material}_axe`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    IngredientAmount.Axe,
                ),
            ),
        new CraftingRecipe(`${namespace}:${material}_shovel`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    IngredientAmount.Shovel,
                ),
            ),
        ...compactMaterialRecipe(
            `${namespace}:${material}`,
            `${namespace}:${material}_block`,
            workbench,
        ),
        new CraftingRecipe(`${namespace}:${material}`)
            .setCraftingStations(furnace)
            .setIngredients(
                new CraftingIngredient(`${namespace}:raw_${material}`),
            ),
    ];
};
