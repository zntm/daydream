import { DatagenReturnData } from "../../../lib";
import { Item, ItemComponent, ItemScript, ItemType } from "../lib";
import { liquidRegistries } from "../registries";

export default liquidRegistries.map(
    ({ namespace, id, flow_speed, fluidCollisions }) =>
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
                        liquid_id: `phantasia:${id}`,
                        empty_bucket_id: "phantasia:bucket",
                        tick_delay: flow_speed,
                        fluid_collisions: fluidCollisions,
                    }),
                ]),
        ),
);
