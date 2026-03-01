import type { LootPool } from "./LootPool";

export class Loot {
    private pools: LootPool[];

    constructor(pools: LootPool[]) {
        this.pools = pools;
    }
}
