import { DatagenReturnData } from "../../../lib";
import { Item, ItemComponent, ItemFunction, ItemType } from "../lib";
import { liquidRegistries } from "../registries";

export default liquidRegistries.map(
    ({ namespace, id, flow_speed, fluid_collisions }) =>
        new DatagenReturnData(
            `${id}_bucket.json`,
            new Item(
                ItemType.Default,
                `${namespace}:item/${id}_bucket`,
                "#phantasia:item/generic/inventory_default",
            )
                .addItemComponent("level", ItemComponent.u8(8, 1, 8))
                .setItemOnUse([
                    new ItemFunction("phantasia:bucket_place", {
                        liquid_id: `phantasia:${id}`,
                        empty_bucket_id: "phantasia:bucket",
                        flow_speed,
                        fluid_collisions,
                    }),
                ]),
        ),
);
