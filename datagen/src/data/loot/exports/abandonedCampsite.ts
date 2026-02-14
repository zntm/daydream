import { DatagenReturnData } from "../../../lib";
import { LootTable, LootPool, LootEntry } from "../lib/Loot";

export default [
    new DatagenReturnData(
        "abandoned_campsite.json",
        new LootTable(
            LootPool.random(
                [
                    LootEntry.item("phantasia:coal", 1, {
                        type: "irandom",
                        values: { min: 2, max: 4 },
                    } as any),
                    LootEntry.item("phantasia:twig", 1, {
                        type: "irandom",
                        values: { min: 1, max: 2 },
                    } as any),
                    LootEntry.empty(2),
                ],
                3,
                8,
            ),
        ).toJSON(),
    ),
];
