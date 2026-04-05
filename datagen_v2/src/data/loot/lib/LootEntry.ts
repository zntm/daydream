import type { LootEntryItem } from "./LootEntryItem";

export class LootEntry {
    private weight: number;
    private item?: LootEntryItem;
    private value?: string;

    constructor(item: string | LootEntryItem, weight: number) {
        this.weight = weight;

        if (typeof item === "string") {
            this.value = item;
        } else {
            this.item = item;
        }
    }
}
