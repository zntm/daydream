import { DatagenReturnData, SmartValue } from "../../../lib";
import {
    ItemParticle,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    TileItemPlacement,
    TileItemProperties,
} from "../lib";

export default [
    new DatagenReturnData(
        "twig.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/twig",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror],
        )
            .setTileDrops([new TileItemDrop("phantasia:twig")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.11,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new TileItemPlacement().setIndex(SmartValue.IntRandom(1, 3)),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0)),
    ),
    new DatagenReturnData(
        "rock.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/rock",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror],
        )
            .setTileDrops([new TileItemDrop("phantasia:rock")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.11,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new TileItemPlacement().setIndex(SmartValue.IntRandom(1, 4)),
            )
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0)),
    ),
];
