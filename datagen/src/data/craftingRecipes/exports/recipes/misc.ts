import { CraftingRecipe, CraftingIngredient, IngredientAmount, RecipeAmount } from "../../lib/Recipe";
import compactMaterialRecipes from "../../lib/groups/compactMaterialRecipes";

export default [
    // Cookable Consumable
    ...["chicken", "rabbit"].map((id) =>
        new CraftingRecipe(
            `phantasia:cooked_${id}`,
            IngredientAmount.MaterialCompact,
        )
            .setCraftingStations("phantasia:furnace")
            .setIngredients(new CraftingIngredient(`phantasia:raw_${id}`)),
    ),
    ...compactMaterialRecipes(
        "phantasia:coal",
        "phantasia:coal_block",
        "#phantasia:tile/generic/workbench",
    ),
    ...[
        "phantasia:dirt",
        "phantasia:nightrock",
        "phantasia:moss",
        "phantasia:sandstone",
        "phantasia:stone",
    ].map((material) =>
        new CraftingRecipe(`${material}_wall`, RecipeAmount.Wall)
            .setCraftingStations("#phantasia:tile/generic/workbench")
            .setIngredients(
                new CraftingIngredient(material, IngredientAmount.Wall),
            ),
    ),
    new CraftingRecipe("phantasia:torch", RecipeAmount.Torch)
        .setCraftingStations("#phantasia:tile/generic/workbench")
        .setIngredients(
            new CraftingIngredient(
                "#phantasia:item/generic/wood",
                IngredientAmount.TorchWood,
            ),
            new CraftingIngredient(
                "phantasia:coal",
                IngredientAmount.TorchCoal,
            ),
        ),
    new CraftingRecipe("phantasia:hatchet").setIngredients(
        new CraftingIngredient("phantasia:twig", 2),
        new CraftingIngredient("phantasia:rock", 2),
    ),
];
