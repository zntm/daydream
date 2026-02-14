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
