import { DatagenReturnData } from "../../../lib";
import {
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    ItemParticle,
    ItemType,
} from "../lib";

export default [
    new DatagenReturnData(
        "furnace.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/furnace",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([
                new TileItemDrop("phantasia:item/furnace").setCondition(
                    new TileItemCondition("#phantasia:item/type/pickaxe", 1),
                ),
            ])
            .setTileHarvest(
                new TileItemHarvest(
                    0.36,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/pickaxe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
];
