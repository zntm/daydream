import type { SmartValue } from "../../../lib/SmartValue";

/**
 * Represents a loot entry in a loot pool
 * Can be either an item with id/amount or a special value like $EMPTY
 */
export class LootEntry {
    private item?: {
        id: string;
        amount?: SmartValue;
    };
    private value?: string;
    private weight: number;

    private constructor(weight: number) {
        this.weight = weight;
    }

    /**
     * Create a loot entry for an item
     */
    static item(id: string, weight: number = 1, amount?: SmartValue): LootEntry {
        const entry = new LootEntry(weight);
        entry.item = { id };
        if (amount !== undefined) {
            entry.item.amount = amount;
        }
        return entry;
    }

    /**
     * Create a loot entry for a special value (e.g., $EMPTY)
     */
    static value(val: string, weight: number = 1): LootEntry {
        const entry = new LootEntry(weight);
        entry.value = val;
        return entry;
    }

    /**
     * Create an empty loot entry (nothing dropped)
     */
    static empty(weight: number = 1): LootEntry {
        return LootEntry.value("$EMPTY", weight);
    }
}

/**
 * Represents a pool of loot entries with roll configuration
 */
export class LootPool {
    private entries: LootEntry[];
    private rolls: SmartValue;

    constructor(entries: LootEntry[], rolls: SmartValue) {
        this.entries = entries;
        this.rolls = rolls;
    }

    /**
     * Create a pool with fixed number of rolls
     */
    static fixed(entries: LootEntry[], rolls: number): LootPool {
        return new LootPool(entries, rolls);
    }

    /**
     * Create a pool with random rolls
     */
    static random(entries: LootEntry[], min: number, max: number): LootPool {
        return new LootPool(entries, {
            type: "irandom",
            values: { min, max }
        });
    }
}

/**
 * Represents a complete loot table with one or more pools
 */
export class LootTable {
    private pools: LootPool[];

    constructor(...pools: LootPool[]) {
        this.pools = pools;
    }

    /**
     * Convert to JSON-serializable array format
     */
    toJSON(): any[] {
        return this.pools;
    }
}
