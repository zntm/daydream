export class CraftingIngredient {
    private id: string;
    private amount: number;

    constructor(id: string, amount: number = 1) {
        this.id = id;
        this.amount = amount;
    }
}
