import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
} from "../lib";

export default [
    new DatagenReturnData(
        "campfire.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/campfire",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new TileItemDrop("phantasia:campfire")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/wood",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileAudioProperties(new TileItemAudioProperties(0.1, 0))
            .setTileLight("#EAC7A6")
            .setAnimationType("increment")
            .setTileOnRandomTick([
                new ItemScript(
                    "@phantasia:items/sfx_play",
                    {
                        id: "phantasia:sfx/tile/fire/ambient",
                    },
                    0.24,
                ),
            ]),
    ),

    new DatagenReturnData(
        "torch.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/torch",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new TileItemDrop("phantasia:torch")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0))
            .setTileLight("#D89172")
            .setAnimationType("increment")
            .setTileOnRandomTick([
                new ItemScript(
                    "@phantasia:items/sfx_play",
                    {
                        id: "phantasia:sfx/tile/fire/ambient",
                    },
                    0.18,
                ),
            ]),
    ),
];
