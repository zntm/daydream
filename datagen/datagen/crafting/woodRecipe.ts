import {
    CraftingIngredient,
    CraftingRecipe,
    IngredientAmount,
    RecipeAmount,
} from "../crafting";

import blockWallRecipe from "./blockWallRecipe";

export enum WoodRecipeAmount {
    Planks = 3,
}

export enum WoodIngredientAmount {
    Workbench = 4,
    Chest = 2,
    ChestFrame = 2,
    PlanksWall = 2,
}

export default (
    namespace: string,
    material: string,
    chestFrame: string,
    workbench: string | string[],
) => {
    return [
        new CraftingRecipe(`${namespace}:${material}_workbench`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    WoodIngredientAmount.Workbench,
                ),
            ),
        new CraftingRecipe(`${namespace}:${material}_chest`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    WoodIngredientAmount.Chest,
                ),
                new CraftingIngredient(
                    chestFrame,
                    WoodIngredientAmount.ChestFrame,
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
        new CraftingRecipe(`${namespace}:${material}_shovel`)
            .setCraftingStations(workbench)
            .setIngredients(
                new CraftingIngredient(
                    `${namespace}:${material}`,
                    IngredientAmount.Shovel,
                ),
            ),
        ...blockWallRecipe(
            `${namespace}:${material}`,
            `${namespace}:${material}_planks`,
            WoodRecipeAmount.Planks,
            `${namespace}:${material}_planks_wall`,
            workbench,
        ),
    ];
};
