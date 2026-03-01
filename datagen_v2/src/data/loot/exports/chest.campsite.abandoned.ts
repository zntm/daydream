import { DatagenReturnData, SmartValue } from "../../../lib";
import { Loot, LootEntry, LootEntryItem, LootPool } from "../lib";

export default new DatagenReturnData(
    "chest/campsite/abandoned.json",
    new Loot([
        new LootPool(SmartValue.IntRandom(3, 8), [
            new LootEntry("$EMPTY", 2),
            new LootEntry(
                new LootEntryItem("phantasia:coal", SmartValue.IntRandom(2, 4)),
                1,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:twig", SmartValue.IntRandom(1, 2)),
                1,
            ),
        ]),
    ]),
);
