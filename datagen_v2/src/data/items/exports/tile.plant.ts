import { DatagenReturnData } from "../../../lib";
import {
    ItemType,
    ItemScript,
    TileItem,
    TileItemAudioProperties,
    TileItemHarvest,
    ItemParticle,
    TileItemPlacement,
    TileItemProperties,
} from "../lib";

export default [
    new DatagenReturnData(
        "cactus_flower.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/cactus_flower",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.IsFoliage],
        )
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
            .setTilePlacement(
                new TileItemPlacement().setCondition(
                    "#phantasia:tile/placement/condition_dry_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
    ),
    new DatagenReturnData(
        "dead_bush.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/dead_bush",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror, TileItemProperties.IsFoliage],
        )
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
            .setTilePlacement(
                new TileItemPlacement().setCondition(
                    "#phantasia:tile/placement/condition_dry_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
    ),
    new DatagenReturnData(
        "cobweb.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/cobweb",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileOnStay([new ItemScript("@phantasia:tile/cobweb/stay")])
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setTileAudioProperties(new TileItemAudioProperties(0.5, 0.3))
            .setTileHarvest(
                new TileItemHarvest(
                    0,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/plant",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            ),
    ),
];
