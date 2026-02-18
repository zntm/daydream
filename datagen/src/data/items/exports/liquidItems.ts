import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemComponent,
    ItemScript,
    ItemType,
    TileItem,
    TileItemProperties,
} from "../lib";
import liquidRegistries from "../registries/liquid";

export default [
    // Empty bucket item
    new DatagenReturnData(
        "bucket.json",
        new Item(
            ItemType.Default,
            "phantasia:item/bucket",
            "#phantasia:item/generic/inventory_default",
        ),
    ),

    // Liquid items and their buckets
    ...liquidRegistries.map(({ id, tick_delay, fluid_collisions }) => {
        return [
            // Liquid tile
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.IsLiquid],
                )
                    .addTileComponent("level", ItemComponent.u8(8, 1, 8))
                    .addTileComponent("flow_direction", ItemComponent.s8(0, -1, 1))
                    .addOnUse([
                        new ItemScript("@phantasia:items/bucket_pickup", {
                            bucket_id: "phantasia:bucket",
                            filled_bucket_id: `phantasia:${id}_bucket`,
                            tick_delay,
                        }),
                    ]),
            ),
            // Filled bucket item
            new DatagenReturnData(
                `${id}_bucket.json`,
                new Item(
                    ItemType.Default,
                    `phantasia:item/${id}_bucket`,
                    "#phantasia:item/generic/inventory_default",
                )
                    .addItemComponent("level", ItemComponent.u8(8, 1, 8))
                    .setItemOnUse([
                        new ItemScript("@phantasia:items/bucket_place", {
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
