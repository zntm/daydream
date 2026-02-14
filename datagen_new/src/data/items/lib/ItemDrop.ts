import type { SmartValueValueType } from "../../../lib";

export class ItemDrop {
    private id: string;
    private amount?: number | string | SmartValueValueType;
    private chance?: number;

    constructor(
        id: string,
        amount?: number | string | SmartValueValueType,
        chance?: number,
    ) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }
}
