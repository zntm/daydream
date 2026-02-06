import type { SmartValueValueType } from "../../../lib";

export class LootEntryItem {
    private id: string;
    private amount?: string | number | SmartValueValueType;

    constructor(id: string, amount?: string | number | SmartValueValueType) {
        this.id = id;
        this.amount = amount;
    }
}
