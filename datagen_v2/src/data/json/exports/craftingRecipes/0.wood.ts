import { woodRegistries } from "../../../items/registries";
import { CraftingIngredient, CraftingRecipe } from "../../craftingRecipes/lib";
import { blockWallRecipes } from "../../craftingRecipes/lib/groups";
import { CraftingIngredientAmount } from "../../craftingRecipes/registries";

enum WoodCraftingIngredientAmount {
    Workbench = 4,
    Chest = 2,
    ChestFrame = 2,
    PlanksWall = 2,
}

export default woodRegistries.map(({ namespace, id }) => [
    new CraftingRecipe(`${namespace}:${id}_chest`).setIngredients([
        new CraftingIngredient(
            `${namespace}:${id}`,
            WoodCraftingIngredientAmount.Chest,
        ),
        new CraftingIngredient(
            `phantasia:iron`,
            WoodCraftingIngredientAmount.ChestFrame,
        ),
    ]),
    new CraftingRecipe(`${namespace}:${id}_workbench`).setIngredients([
        new CraftingIngredient(
            `${namespace}:${id}`,
            WoodCraftingIngredientAmount.Workbench,
        ),
    ]),
    new CraftingRecipe(`${namespace}:${id}_planks`).setIngredients([
        new CraftingIngredient(`${namespace}:${id}`, 3),
    ]),
    blockWallRecipes(
        `${namespace}:${id}_planks`,
        "#phantasia:tile/generic/workbench",
    ),
    new CraftingRecipe(`${namespace}:${id}_pickaxe`).setIngredients([
        new CraftingIngredient(
            `${namespace}:${id}`,
            CraftingIngredientAmount.Pickaxe,
        ),
    ]),
    new CraftingRecipe(`${namespace}:${id}_shovel`).setIngredients([
        new CraftingIngredient(
            `${namespace}:${id}`,
            CraftingIngredientAmount.Shovel,
        ),
    ]),
]);
