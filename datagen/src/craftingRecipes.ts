import { DatagenReturnData } from "../index";

export class CraftingRecipe {
    private id: string;
    private amount: number;
    private crafting_stations?: string | string[];
    private ingredients: CraftingIngredient[];

    constructor(id: string, amount: number = 1) {
        this.id = id;
        this.amount = amount;
        this.ingredients = [];
    }

    setCraftingStations(stations: string | string[]) {
        this.crafting_stations = stations;

        return this;
    }

    setIngredients(...ingredients: CraftingIngredient[]) {
        this.ingredients = ingredients.map(
            (ingredient: any) =>
                new CraftingIngredient(ingredient.id, ingredient?.amount),
        );

        return this;
    }
}

export class CraftingIngredient {
    private id: string;
    private amount: number;

    constructor(id: string, amount: number = 1) {
        this.id = id;
        this.amount = amount;
    }
}

export enum RecipeAmount {
    Torch = 6,
    Wall = 2,
}

export enum IngredientAmount {
    Sword = 12,
    Pickaxe = 10,
    Axe = 10,
    Shovel = 8,
    MaterialCompact = 8,
    TorchWood = 2,
    TorchCoal = 2,
    Wall = 3,
}

import compactMaterialRecipes from "./craftingRecipes/compactMaterialRecipes";
import tieredEquipmentRecipes from "./craftingRecipes/tieredEquipmentRecipes";
import woodRecipes from "./craftingRecipes/woodRecipes";

export default new DatagenReturnData("generated/data/json/crafting.json", [
    // Cookable Consumable
    ...["chicken", "rabbit"].map((id) =>
        new CraftingRecipe(
            `phantasia:cooked_${id}`,
            IngredientAmount.MaterialCompact,
        )
            .setCraftingStations("phantasia:furnace")
            .setIngredients(new CraftingIngredient(`phantasia:raw_${id}`)),
    ),
    // Tiered Equipment
    ...["platinum", "gold", "iron", "copper"]
        .map((id) =>
            tieredEquipmentRecipes(
                "phantasia",
                id,
                "#phantasia:tile/generic/workbench",
                "phantasia:furnace",
            ),
        )
        .flat(),
    ...compactMaterialRecipes(
        "phantasia:coal",
        "phantasia:coal_block",
        "#phantasia:tile/generic/workbench",
    ),
    // Wood
    ...["birch", "oak", "pine"]
        .map((id) =>
            woodRecipes(
                "phantasia",
                id,
                "phantasia:iron",
                "#phantasia:tile/generic/workbench",
            ),
        )
        .flat(),
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
]);
