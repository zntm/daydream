import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { LootTable, LootPool, LootEntry } from "./lib/Loot";

export { LootTable, LootPool, LootEntry };

// Define loot tables here
const lootTables: Record<string, LootTable> = {
    // Example: abandoned_campsite loot table
    "abandoned_campsite": new LootTable(
        LootPool.random([
            LootEntry.item("phantasia:coal", 1, {
                type: "irandom",
                values: { min: 2, max: 4 }
            }),
            LootEntry.item("phantasia:twig", 1, {
                type: "irandom",
                values: { min: 1, max: 2 }
            }),
            LootEntry.empty(2)
        ], 3, 8)
    ),
};

export default Object.entries(lootTables).map(([name, table]) => {
    return new DatagenReturnData(`generated/data/loot/${name}.json`, table.toJSON());
});
