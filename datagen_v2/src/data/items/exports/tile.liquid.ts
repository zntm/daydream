import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemComponent,
    ItemScript,
    ItemType,
    TileItem,
    TileItemProperties,
} from "../lib";
import { liquidRegistries } from "../registries";

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
    ...liquidRegistries
        .map(({ id, namespace, flow_speed, fluidCollisions, item_drop_modifier }) => {
            return [
                // Liquid tile
                new DatagenReturnData(
                    `${id}.json`,
                    new TileItem(
                        ItemType.Untouchable,
                        `${namespace}:item/${id}`,
                        "#phantasia:item/generic/inventory_default",
                        [TileItemProperties.IsLiquid],
                    )
                        .setLiquidFlowSpeed(flow_speed)
                        .setLiquidCollisions(fluidCollisions)
                        .addTileComponent("level", ItemComponent.u8(8, 1, 8))
                        .addTileComponent(
                            "flow_direction",
                            ItemComponent.s8(0, -1, 1),
                        )
                        .setItemDropModifier(item_drop_modifier)
                        .addOnUse([
                            new ItemScript("@phantasia:items/bucket_pickup", {
                                bucket_id: "phantasia:bucket",
                                filled_bucket_id: `${namespace}:${id}_bucket`,
                                tick_delay: flow_speed,
                            }),
                        ]),
                ),
                // Filled bucket item
                new DatagenReturnData(
                    `${id}_bucket.json`,
                    new Item(
                        ItemType.Default,
                        `${namespace}:item/${id}_bucket`,
                        "#phantasia:item/generic/inventory_default",
                    )
                        .addItemComponent("level", ItemComponent.u8(8, 1, 8))
                        .setItemOnUse([
                            new ItemScript("@phantasia:items/bucket_place", {
                                liquid_id: `${namespace}:${id}`,
                                empty_bucket_id: "phantasia:bucket",
                                tick_delay: flow_speed,
                                fluid_collisions: fluidCollisions,
                            }),
                        ]),
                ),
            ];
        })
        .flat(),
];
