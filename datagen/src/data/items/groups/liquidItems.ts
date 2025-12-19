import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { TileItem, TileItemProperties } from "../lib/TileItem";
import { ItemComponent } from "../lib/ItemComponent";
import { ItemFunction } from "../lib/ItemFunction";
import { UseableItem } from "../lib/Item";

export default [
    // Empty bucket item
    new DatagenReturnData(
        "generated/data/items/bucket.json",
        new UseableItem(
            ItemType.Default,
            "phantasia:item/bucket",
            "#phantasia:item/generic/inventory_default",
        ),
    ),

    // Liquid items and their buckets
    [
        {
            id: "lava",
            tick_delay: 1,
            fluid_collisions: [
                { id: "phantasia:stone", liquid_id: "phantasia:water" },
            ],
        },
        {
            id: "water",
            tick_delay: 5,
            fluid_collisions: [
                { id: "phantasia:stone", liquid_id: "phantasia:lava" },
            ],
        },
    ].map(({ id, tick_delay, fluid_collisions }) => {
        return [
            // Liquid tile (no on_random_tick - uses tick_delay instead)
            new DatagenReturnData(
                `generated/data/items/${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.IsLiquid],
                )
                    .addComponent("level", ItemComponent.u8(8, 1, 8))
                    .addComponent("flow_direction", ItemComponent.s8(0, -1, 1))
                    .addOnUse([
                        new ItemFunction("phantasia:bucket_pickup", {
                            bucket_id: "phantasia:bucket",
                            filled_bucket_id: `phantasia:${id}_bucket`,
                            tick_delay,
                        }),
                    ]),
            ),
            // Filled bucket item (useable, not tile)
            new DatagenReturnData(
                `generated/data/items/${id}_bucket.json`,
                new UseableItem(
                    ItemType.Default,
                    `phantasia:item/${id}_bucket`,
                    "#phantasia:item/generic/inventory_default",
                )
                    .addComponent("level", ItemComponent.u8(8, 1, 8))
                    .addOnUse([
                        new ItemFunction("phantasia:bucket_place", {
                            liquid_id: `phantasia:${id}`,
                            empty_bucket_id: "phantasia:bucket",
                            tick_delay,
                            fluid_collisions,
                        }),
                    ]),
            ),
        ];
    }),
];
