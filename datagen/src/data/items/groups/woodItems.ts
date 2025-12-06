import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTilePlacementCondition,
    ItemTilePlacementConditionType,
    ItemTilePlacementConditionValue,
    ItemTileProperties,
} from "../lib/TileItem";
import { ToolItem } from "../lib/ToolItem";

const { default: blockWallItems } = import.meta.require("./blockWallItems");

export default (
    id: string,
    leavesParticleId: string | string[],
    logParticleId: string | string[],
    plankParticleId: string | string[],
) => [
    new DatagenReturnData(
        `generated/data/items/${id}.json`,
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new ItemTileDrop(`phantasia:${id}`)])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.56,
                    1,
                    new ItemTileParticle(
                        logParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTilePlacement(
                new ItemTilePlacement().setCondition(
                    new ItemTilePlacementCondition(
                        ItemTilePlacementConditionType.Every,
                        [
                            {
                                condition: new ItemTilePlacementCondition(
                                    ItemTilePlacementConditionType.Some,
                                    [
                                        new ItemTilePlacementConditionValue(
                                            0,
                                            1,
                                            "default",
                                        ).setId(
                                            "#phantasia:tile/placement/plant_on",
                                        ),
                                        new ItemTilePlacementConditionValue(
                                            0,
                                            1,
                                            "z",
                                        ).setId("$ID"),
                                    ],
                                ),
                            },
                        ],
                    ),
                ),
            )
            .setAudioProperties(0.4, 0.1),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_chest.json`,
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}_chest`,
            "#phantasia:item/generic/inventory_tile",
        )
            .setTileDrops([new ItemTileDrop(`phantasia:${id}_chest`)])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.56,
                    1,
                    new ItemTileParticle(
                        plankParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.4, 0.1),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_leaves.json`,
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}_leaves`,
            "#phantasia:item/generic/inventory_tile",
            [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
        )
            // .setTileDrops([new ItemTileDrop(`phantasia:${id}_leaves`)])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.44,
                    1,
                    new ItemTileParticle(
                        leavesParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.2, 0.0),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_pickaxe.json`,
        new ToolItem(
            `${id}_pickaxe`,
            73,
            "#phantasia:item/generic/durability_bar",
            undefined,
            1,
            1,
        ),
    ),
    ...blockWallItems(
        `${id}_planks`,
        [ItemTileProperties.IsTile],
        new ItemTileHarvest(
            0.44,
            1,
            new ItemTileParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        "#phantasia:tile/sfx/wood",
        0.4,
        0.1,
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_shovel.json`,
        new ToolItem(
            `${id}_shovel`,
            65,
            "#phantasia:item/generic/durability_bar",
            undefined,
            1,
            1,
        ),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_workbench.json`,
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}_workbench`,
            "#phantasia:item/generic/inventory_tile",
        )
            .setTileDrops([new ItemTileDrop(`phantasia:${id}_workbench`)])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.36,
                    1,
                    new ItemTileParticle(
                        plankParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.4, 0.1),
    ),
];
