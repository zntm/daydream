import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { SmartValueIntRandom } from "../../../lib/SmartValue";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    TileItemDrop,
    TileItemHarvest,
    TileItemParticle,
    TileItemPlacement,
    TileItemProperties,
} from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/twig.json",
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
                    new TileItemParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new TileItemPlacement().setIndex(new SmartValueIntRandom(1, 3)),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.05, 0.0),
    ),
    new DatagenReturnData(
        "generated/data/items/rock.json",
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
                    new TileItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new TileItemPlacement().setIndex(new SmartValueIntRandom(1, 4)),
            )
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setAudioProperties(0.05, 0.0),
    ),
];
