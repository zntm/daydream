import { DatagenReturnData, SmartValue } from "../../../lib";
import { Loot, LootEntry, LootEntryItem, LootPool } from "../lib";

export default new DatagenReturnData(
    "pot/generic.json",
    new Loot([
        new LootPool(1, [
            new LootEntry(
                new LootEntryItem("phantasia:twig", SmartValue.IntRandom(2, 3)),
                3,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:rock", SmartValue.IntRandom(2, 3)),
                3,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:coal", SmartValue.IntRandom(1, 2)),
                1,
            ),
        ]),
    ]),
);
