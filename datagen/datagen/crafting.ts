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

import compactMaterialRecipe from "./crafting/compactMaterialRecipe";
import tieredEquipmentRecipe from "./crafting/tieredEquipmentRecipe";
import woodRecipe from "./crafting/woodRecipe";

export default new DatagenReturnData("generated/data/json/crafting.json", [
    ...tieredEquipmentRecipe(
        "phantasia",
        "gold",
        "#phantasia:tile/generic/workbench",
        "phantasia:furnace",
    ),
    ...tieredEquipmentRecipe(
        "phantasia",
        "iron",
        "#phantasia:tile/generic/workbench",
        "phantasia:furnace",
    ),
    ...tieredEquipmentRecipe(
        "phantasia",
        "copper",
        "#phantasia:tile/generic/workbench",
        "phantasia:furnace",
    ),
    ...compactMaterialRecipe(
        "phantasia:coal",
        "phantasia:coal_block",
        "#phantasia:tile/generic/workbench",
    ),
    ...woodRecipe(
        "phantasia",
        "birch",
        "phantasia:iron",
        "#phantasia:tile/generic/workbench",
    ),
    ...woodRecipe(
        "phantasia",
        "oak",
        "phantasia:oak",
        "#phantasia:tile/generic/workbench",
    ),
    ...woodRecipe(
        "phantasia",
        "pine",
        "phantasia:iron",
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
]);
