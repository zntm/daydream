import CraftingIngredientAmount from "../../registries/craftingIngredientAmount";
import { CraftingIngredient } from "../CraftingIngredient";
import { CraftingRecipe } from "../CraftingRecipe";

export default (rawMaterial: string, workbench: string | string[]) => [
    new CraftingRecipe(`${rawMaterial}_block`)
        .setCraftingStations(workbench)
        .setIngredients([
            new CraftingIngredient(
                rawMaterial,
                CraftingIngredientAmount.MaterialCompact,
            ),
        ]),
    new CraftingRecipe(rawMaterial, CraftingIngredientAmount.MaterialCompact)
        .setCraftingStations(workbench)
        .setIngredients([new CraftingIngredient(`${rawMaterial}_block`)]),
];
