import type { LootEntryItem } from "./LootEntryItem";

export class LootEntry {
    private item: string | LootEntryItem;
    private weight: number;

    constructor(item: string | LootEntryItem, weight: number) {
        this.item = item;
        this.weight = weight;
    }
}
