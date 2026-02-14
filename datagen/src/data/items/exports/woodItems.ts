import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemPlacement,
    TileItemPlacementCondition,
    TileItemPlacementConditionType,
    TileItemPlacementConditionValue,
    TileItemProperties,
    TileItemAudioProperties,
    ToolItem,
} from "../lib";
import blockWallItems from "../lib/groups/tile.blockWall";
import woodRegistries from "../registries/wood";

export default [
    ...woodRegistries.map(({ id, leavesParticles, logParticles, planksParticles }) => [
        new DatagenReturnData(
            `${id}.json`,
            new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}`,
                "#phantasia:item/generic/inventory_default",
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
                .setTileHarvest(
                    new TileItemHarvest(
                        0.56,
                        1,
                        new ItemParticle(
                            logParticles,
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                        new TileItemCondition("#phantasia:item/type/axe"),
                    ),
                )
                .setTileSFX("#phantasia:tile/sfx/wood")
                .setTilePlacement(
                    new TileItemPlacement().setCondition(
                        new TileItemPlacementCondition(
                            TileItemPlacementConditionType.Every,
                            [
                                {
                                    condition: new TileItemPlacementCondition(
                                        TileItemPlacementConditionType.Some,
                                        [
                                            new TileItemPlacementConditionValue(
                                                0,
                                                1,
                                                "default",
                                            ).setId(
                                                "#phantasia:tile/placement/plant_on",
                                            ),
                                            new TileItemPlacementConditionValue(
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
                .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
        ),
        new DatagenReturnData(
            `${id}_chest.json`,
            new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}_chest`,
                "#phantasia:item/generic/inventory_tile",
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}_chest`)])
                .setTileHarvest(
                    new TileItemHarvest(
                        0.56,
                        1,
                        new ItemParticle(
                            planksParticles,
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                        new TileItemCondition("#phantasia:item/type/axe"),
                    ),
                )
                .setTileSFX("#phantasia:tile/sfx/wood")
                .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
        ),
        new DatagenReturnData(
            `${id}_leaves.json`,
            new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}_leaves`,
                "#phantasia:item/generic/inventory_tile",
                [
                    TileItemProperties.CanFlip,
                    TileItemProperties.CanMirror,
                    TileItemProperties.IsTile,
                ],
            )
                .setTileHarvest(
                    new TileItemHarvest(
                        0.44,
                        1,
                        new ItemParticle(
                            leavesParticles,
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                        new TileItemCondition("#phantasia:item/type/axe"),
                    ),
                )
                .setTileSFX("#phantasia:tile/sfx/wood")
                .setTileAudioProperties(new TileItemAudioProperties(0.2, 0.0))
                .setTileOnRandomTick([
                    new ItemScript("@phantasia:tile/nature/leaf_decay", {
                        id: `phantasia:tile/leaf/${id}`,
                    }, 0.03),
                ]),
        ),
        new DatagenReturnData(
            `${id}_pickaxe.json`,
            new ToolItem(
                `phantasia:item/${id}_pickaxe`,
                1, // damage
                73, // durability
                1, // harvestHardness
                1, // harvestLevel
            ),
        ),
        ...blockWallItems(
            `${id}_planks`,
            [TileItemProperties.IsTile],
            new TileItemHarvest(
                0.44,
                1,
                new ItemParticle(
                    planksParticles,
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/axe"),
            ),
            "#phantasia:tile/sfx/wood",
            0.4,
            0.1,
        ),
        new DatagenReturnData(
            `${id}_shovel.json`,
            new ToolItem(
                `phantasia:item/${id}_shovel`,
                1, // damage
                65, // durability
                1, // harvestHardness
                1, // harvestLevel
            ),
        ),
        new DatagenReturnData(
            `${id}_workbench.json`,
            new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}_workbench`,
                "#phantasia:item/generic/inventory_tile",
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}_workbench`)])
                .setTileHarvest(
                    new TileItemHarvest(
                        0.36,
                        1,
                        new ItemParticle(
                            planksParticles,
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                        new TileItemCondition("#phantasia:item/type/axe"),
                    ),
                )
                .setTileSFX("#phantasia:tile/sfx/wood")
                .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
        ),
    ]),
    new DatagenReturnData(
        `mangrove_roots.json`,
        new TileItem(
            ItemType.Solid,
            `phantasia:item/mangrove_roots`,
            "#phantasia:item/generic/inventory_tile",
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
        )
            .setTileDrops([new TileItemDrop(`phantasia:mangrove`)])
            .setTileHarvest(
                new TileItemHarvest(
                    0.56,
                    1,
                    new ItemParticle(
                        ["#4D2D0B", "#3F2207"],
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
    ),
];
