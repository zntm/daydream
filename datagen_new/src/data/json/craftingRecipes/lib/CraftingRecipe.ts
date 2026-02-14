import { CraftingIngredient } from "./CraftingIngredient";

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

    setIngredients(ingredients: CraftingIngredient[]) {
        this.ingredients = ingredients.map(
            (ingredient: any) =>
                new CraftingIngredient(ingredient.id, ingredient?.amount),
        );

        return this;
    }
}
