import type { SmartValueValueType } from "../../../lib";
import type { LootEntry } from "./LootEntry";

export class LootPool {
    private entries: LootEntry[];
    private rolls: string | number | SmartValueValueType;

    constructor(
        rolls: string | number | SmartValueValueType,
        entries: LootEntry[],
    ) {
        this.entries = entries;
        this.rolls = rolls;
    }
}
