import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import {
    TileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
} from "../lib/TileItem";
import { ItemType } from "../lib/ItemType";

export default [
    new DatagenReturnData(
        "generated/data/items/furnace.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/furnace",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([
                new ItemTileDrop("phantasia:item/furnace").setCondition(
                    new ItemTileCondition("#phantasia:item/type/pickaxe", 1),
                ),
            ])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.36,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/pickaxe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
];

