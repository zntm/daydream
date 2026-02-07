import { CraftingIngredient, CraftingRecipe } from "../../craftingRecipes/lib";
import { CraftingIngredientAmount } from "../../craftingRecipes/registries";

export default [
    "phantasia:copper",
    "phantasia:iron",
    "phantasia:gold",
    "phantasia:platinum",
].map((id) => [
    new CraftingRecipe(`${id}_sword`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Sword),
        ]),
    new CraftingRecipe(`${id}_pickaxe`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Pickaxe),
        ]),
    new CraftingRecipe(`${id}_axe`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Axe),
        ]),
    new CraftingRecipe(`${id}_shovel`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Shovel),
        ]),
    new CraftingRecipe(`${id}_helmet`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Helmet),
        ]),
    new CraftingRecipe(`${id}_breastplate`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Breastplate),
        ]),
    new CraftingRecipe(`${id}_leggings`)
        .setCraftingStations("phantasia:anvil")
        .setIngredients([
            new CraftingIngredient(id, CraftingIngredientAmount.Leggings),
        ]),
]);
