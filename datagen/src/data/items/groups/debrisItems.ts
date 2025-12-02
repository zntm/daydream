import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { SmartValueIntRandom } from "../../../lib/SmartValue";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTileProperties,
    ItemTileSFX,
} from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/twig.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/twig",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror],
        )
            .setTileDrops([new ItemTileDrop("phantasia:twig")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.11,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new ItemTilePlacement().setIndex(
                    new SmartValueIntRandom(1, 3),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood"),
    ),
    new DatagenReturnData(
        "generated/data/items/rock.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/rock",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror],
        )
            .setTileDrops([new ItemTileDrop("phantasia:rock")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.11,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new ItemTilePlacement().setIndex(
                    new SmartValueIntRandom(1, 4),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
];
