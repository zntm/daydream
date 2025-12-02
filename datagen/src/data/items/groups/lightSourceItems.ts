import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { ItemFunction } from "../lib/ItemFunction";
import {
    TileItem,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
} from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/campfire.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/campfire",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new ItemTileDrop("phantasia:campfire")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.38,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/wood",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                )
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileLight("#EAC7A6")
            .setAnimationType("increment")
            .addOnRandomTick([
                new ItemFunction("phantasia:sfx_play", [{ id: "phantasia:tile.fire.ambient" }])
            ], 0.24)
    ),

    new DatagenReturnData(
        "generated/data/items/torch.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/torch",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new ItemTileDrop("phantasia:torch")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.38,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                )
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileLight("#D89172")
            .setAnimationType("increment")
            .addOnRandomTick([
                new ItemFunction("phantasia:sfx_play", [{ id: "phantasia:tile.fire.ambient" }])
            ], 0.1)
    ),
];
