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
<<<<<<< HEAD:datagen_new/src/data/items/exports/tile.wood.ts
    ...woodRegistries.map(
        ({ namespace, id, leaves, logParticles, planksParticles }) => [
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Solid,
                    `${namespace}:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
=======
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
>>>>>>> region:datagen/src/data/items/exports/woodItems.ts
                )
                    .setTileDrops([new TileItemDrop(`${namespace}:${id}`)])
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
                                    new TileItemPlacement().setCondition(
                                        new TileItemPlacementCondition(
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
                                    ),
                                ],
                            ),
                        ),
                    ),
            ),
            new DatagenReturnData(
                `${id}_chest.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `${namespace}:item/${id}_chest`,
                    "#phantasia:item/generic/inventory_tile",
                )
                    .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1))
                    .setTileDrops([new TileItemDrop(`${namespace}:${id}_chest`)])
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
                    .setTileSFX("#phantasia:tile/sfx/wood"),
            ),
            ...leaves.map(
                (leaf) =>
                    new DatagenReturnData(
                        `${leaf.id}.json`,
                        new TileItem(
                            ItemType.Untouchable,
                            `${namespace}:item/${leaf.id}`,
                            "#phantasia:item/generic/inventory_tile",
                            [
<<<<<<< HEAD:datagen_new/src/data/items/exports/tile.wood.ts
                                TileItemProperties.CanFlip,
                                TileItemProperties.CanMirror,
                                TileItemProperties.IsTile,
                            ],
                        )
                            .setTileAudioProperties(
                                new TileItemAudioProperties(0.4, 0.1),
                            )
                            .setTileHarvest(
                                new TileItemHarvest(
                                    0.18,
                                    1,
                                    new ItemParticle(
                                        leaf.particles,
                                        "#phantasia:tile/generic/harvest_particle_frequency",
                                    ),
                                    new TileItemCondition(
                                        "#phantasia:item/type/axe",
                                    ),
                                ),
                            )
                            .setTileSFX("#phantasia:tile/sfx/leaves")
                            .setTileOnRandomTick([
                                new ItemScript("@phantasia:tile/leaf_decay", undefined, 0.1),
                            ]),
                    ),
            ),
            tileBlockWallItems(
                namespace,
                `${id}_planks`,
                [TileItemProperties.IsTile],
                new TileItemHarvest(
                    0.44,
                    1,
                    new ItemParticle(
                        planksParticles,
                        "#phantasia:tile/generic/harvest_particle_frequency",
=======
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
>>>>>>> region:datagen/src/data/items/exports/woodItems.ts
                    ),
                    new TileItemCondition("#phantasia:item/type/axe"),
                ),
                "#phantasia:tile/sfx/wood",
                new TileItemAudioProperties(0.4, 0.1),
            ),
            new DatagenReturnData(
                `${id}_workbench.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}_workbench`,
                    "#phantasia:item/generic/inventory_tile",
                    [
                        TileItemProperties.CanFlip,
                        TileItemProperties.CanMirror,
                        TileItemProperties.IsTile,
                    ],
                )
<<<<<<< HEAD:datagen_new/src/data/items/exports/tile.wood.ts
                    .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1))
                    .setTileDrops([
                        new TileItemDrop(`${namespace}:${id}_workbench`),
                    ])
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
                    .setTileSFX("#phantasia:tile/sfx/wood"),
            ),
        ],
    ),
    new DatagenReturnData(
        "mangrove_roots.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/mangrove_roots",
=======
                .setTileSFX("#phantasia:tile/sfx/wood")
                .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
        ),
    ]),
    new DatagenReturnData(
        `mangrove_roots.json`,
        new TileItem(
            ItemType.Solid,
            `phantasia:item/mangrove_roots`,
>>>>>>> region:datagen/src/data/items/exports/woodItems.ts
            "#phantasia:item/generic/inventory_tile",
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
        )
<<<<<<< HEAD:datagen_new/src/data/items/exports/tile.wood.ts
            .setTileDrops([new TileItemDrop("phantasia:mangrove")])
=======
            .setTileDrops([new TileItemDrop(`phantasia:mangrove`)])
>>>>>>> region:datagen/src/data/items/exports/woodItems.ts
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
