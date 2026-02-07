import { DatagenReturnData } from "../../../lib";
import { ItemComponent, ItemScript, ItemType, TileItem, TileItemProperties } from "../lib";
import { liquidRegistries } from "../registries";

export default liquidRegistries.map(
    ({ namespace, id, flow_speed, fluid_collisions }) =>
        new DatagenReturnData(
            `${id}.json`,
            new TileItem(
                ItemType.Untouchable,
                `${namespace}:item/${id}`,
                "#phantasia:item/generic/inventory_default",
                [TileItemProperties.IsLiquid],
            )
                .addTileComponent("level", ItemComponent.u8(8, 1, 8))
                .addTileComponent("flow_direction", ItemComponent.s8(0, -1, 1))
                .addOnUse([
                    new ItemScript("@phantasia:item/bucket_pickup", {
                        bucket_id: "phantasia:bucket",
                        filled_bucket_id: `${namespace}:${id}_bucket`,
                        flow_speed,
                    }),
                ]),
        ),
);
