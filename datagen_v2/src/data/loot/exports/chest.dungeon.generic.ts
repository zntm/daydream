import { DatagenReturnData, SmartValue } from "../../../lib";
import { Loot, LootEntry, LootEntryItem, LootPool } from "../lib";

export default new DatagenReturnData(
    "chest/dungeon/generic.json",
    new Loot([
        new LootPool(SmartValue.IntRandom(3, 8), [
            new LootEntry("$EMPTY", 8),
            new LootEntry(
                new LootEntryItem("phantasia:coal", SmartValue.IntRandom(2, 4)),
                1,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:twig", SmartValue.IntRandom(1, 2)),
                5,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:bone", SmartValue.IntRandom(3, 6)),
                2,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:zombie_flesh", SmartValue.IntRandom(2, 4)),
                1,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:oak", SmartValue.IntRandom(1, 6)),
                4,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:raw_copper", SmartValue.IntRandom(1, 4)),
                2,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:raw_iron", SmartValue.IntRandom(1, 4)),
                2,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:copper", SmartValue.IntRandom(1, 2)),
                1,
            ),
            new LootEntry(
                new LootEntryItem("phantasia:iron", SmartValue.IntRandom(1, 2)),
                1,
            ),
        ]),
    ]),
);
