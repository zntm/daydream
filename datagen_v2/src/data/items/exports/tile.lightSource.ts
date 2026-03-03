import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";

export default [
    new DatagenReturnData(
        "campfire.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/campfire",
            "#phantasia:item/generic/inventory_default",
        )
            .setAnimationType("increment")
            .setTileAudioProperties(new TileItemAudioProperties(0.1, 0))
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
            .setTileLight("#EAC7A6")
            .setTileOnRandomTick([
                new ItemScript(
                    "@phantasia:items/sfx_play",
                    {
                        id: "phantasia:sfx/tile/fire/ambient",
                    },
                    0.24,
                ),
            ])
            .setTileSFX("#phantasia:tile/sfx/wood"),
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
    new DatagenReturnData(
        "lumin_bulb.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/lumin_bulb",
            "#phantasia:item/generic/inventory_tile",
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
        )
            .setTileDrops([new TileItemDrop("phantasia:lumin_bulb")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.26,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/lumin_moss",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0))
            .setTileLight("#DBEDFF"),
    ),
];
