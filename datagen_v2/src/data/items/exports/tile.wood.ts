import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemPlacement,
    TileItemPlacementCondition,
    TileItemPlacementConditionType,
    TileItemPlacementConditionValue,
    TileItemProperties,
} from "../lib";
import { tileBlockWallItems } from "../lib/groups";
import { woodRegistries } from "../registries";

export default woodRegistries.map(
    ({ namespace, id, logParticles, planksParticles, leafRegistries }) => [
        new DatagenReturnData(
            `${id}.json`,
            new TileItem(
                ItemType.Untouchable,
                `${namespace}:item/${id}`,
                "phantasia:item/generic/inventory_default",
            )
                .setTileDrops([new TileItemDrop(`${namespace}:item/${id}`)])
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
        leafRegistries?.map((leaf) => {
            const leafId =
                leaf.id.length > 0 ? `${leaf.id}_${id}_leaves` : `${id}_leaves`;

            return new DatagenReturnData(
                `${leafId}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `${namespace}:item/${leafId}`,
                    "#phantasia:item/generic/inventory_tile",
                    [
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
                            new TileItemCondition("#phantasia:item/type/axe"),
                        ),
                    )
                    .setTileSFX("#phantasia:tile/sfx/leaves")
                    .setTileOnRandomTick([
                        new ItemScript("@phantasia:tile/leaf_decay", 0.1),
                    ]),
            );
        }),
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
);
