import type { SmartValue } from "../../../lib/SmartValue";

export class ItemDrop {
    private id: string;
    private amount?: number | SmartValue;
    private chance?: number;

    constructor(id: string, amount?: number | SmartValue, chance?: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }
}
