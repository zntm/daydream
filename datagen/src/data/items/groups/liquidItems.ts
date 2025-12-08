import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { TileItem } from "../lib/TileItem";
import { ItemIntegerComponent } from "../lib/ItemComponent";
import { ItemFunction } from "../lib/ItemFunction";
import { Item } from "../lib/Item";

export default [
    ["water"].map((id: string) => {
        return [
            new DatagenReturnData(
                `generated/data/items/${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                )
                    .addComponent("level", new ItemIntegerComponent(8, 1, 8))
                    .addComponent(
                        "flow_direction",
                        new ItemIntegerComponent(0, -1, 1),
                    )
                    .addOnRandomTick([
                        new ItemFunction("phantasia:liquid_flow"),
                    ]),
            ),
            new DatagenReturnData(
                `generated/data/items/${id}_bucket.json`,
                new Item(
                    ItemType.Untouchable,
                    `phantasia:item/${id}_flowing`,
                    "#phantasia:item/generic/inventory_default",
                )
                    .addComponent("level", new ItemIntegerComponent(8, 1, 8))
                    .addComponent(
                        "flow_direction",
                        new ItemIntegerComponent(0, -1, 1),
                    )
                    .addOnRandomTick([
                        new ItemFunction("phantasia:liquid_flow"),
                    ]),
            ),
        ];
    }),
];
