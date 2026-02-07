import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import { Loot, LootPool, LootEntry, LootEntryItem } from "../lib";

const abandonedCampsite = new Loot([
    new LootPool(SmartValue.IntRandom(3, 8), [
        new LootEntry(
            new LootEntryItem("phantasia:coal", SmartValue.IntRandom(2, 4)),
            1
        ),
        new LootEntry(
            new LootEntryItem("phantasia:twig", SmartValue.IntRandom(1, 2)),
            1
        ),
        new LootEntry("$EMPTY", 2),
    ]),
]);

export default [
    new DatagenReturnData("abandoned_campsite.json", abandonedCampsite),
];
