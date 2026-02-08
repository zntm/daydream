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

export default [
    ...[
        { id: "cactus", particle: "#phantasia:tile/particle_colour/plant" },
        {
            id: "cattail",
            particle: "#phantasia:tile/particle_colour/plant",
            dropIndex: 2,
        },
        {
            id: "sunflower",
            particle: "#phantasia:tile/particle_colour/plant",
            dropIndex: 0,
        },
    ].map(
        ({ id, particle, dropIndex }) =>
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.CanMirror],
                )
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.05, 0),
                    )
                    .setTileDrops([
                        new TileItemDrop(`phantasia:${id}`).setCondition(
                            dropIndex !== undefined
                                ? new TileItemCondition(id).setIndex(dropIndex)
                                : undefined,
                        ),
                    ])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.38,
                            0,
                            new ItemParticle(
                                particle,
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                        ),
                    )
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
                    )
                    .setTileSFX("#phantasia:tile/sfx/foliage"),
            ),
    ),
    ...[
        {
            id: "cactus_flower",
            condition: "#phantasia:tile/placement/condition_dry_plant",
        },
        {
            id: "dead_bush",
            condition: "#phantasia:tile/placement/condition_dry_plant",
            sfx: "#phantasia:tile/sfx/wood",
            particles: "#phantasia:tile/particle_colour/twig",
            drop: "twig",
        },
    ].map(
        ({ id, condition, sfx, particles, drop }) =>
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [
                        TileItemProperties.CanMirror,
                        TileItemProperties.IsFoliage,
                    ],
                )
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.05, 0),
                    )
                    .setTileDrops([new TileItemDrop(`phantasia:${drop || id}`)])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.38,
                            0,
                            new ItemParticle(
                                particles ||
                                    "#phantasia:tile/particle_colour/twig",
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                        ),
                    )
                    .setTilePlacement(
                        new TileItemPlacement().setCondition(condition),
                    )
                    .setTileSFX(sfx || "#phantasia:tile/sfx/foliage"),
            ),
    ),
    new DatagenReturnData(
        "seeding_dandelion.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/seeding_dandelion",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror, TileItemProperties.IsFoliage],
        )
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0))
            .setTileDrops([new TileItemDrop("phantasia:seeding_dandelion")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/plant",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new TileItemPlacement().setCondition(
                    "#phantasia:tile/placement/condition_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setTileOnRandomTick([
                new ItemScript("items/spawn_particle", {
                    id: "phantasia:tile/seeding_dandelion",
                }),
            ]),
    ),
    ...["grass", "grass_dry", "grass_swamp", "grass_taiga"].flatMap((id) =>
        ["short", "tall"].map(
            (type) =>
                new DatagenReturnData(
                    `${type}_${id}.json`,
                    new TileItem(
                        ItemType.Untouchable,
                        `phantasia:item/${type}_${id}`,
                        "#phantasia:item/generic/inventory_default",
                        [
                            TileItemProperties.CanMirror,
                            TileItemProperties.IsFoliage,
                        ],
                    )
                        .setTileAudioProperties(
                            new TileItemAudioProperties(0.05, 0),
                        )
                        .setTileHarvest(
                            new TileItemHarvest(
                                0.38,
                                0,
                                new ItemParticle(
                                    "#phantasia:tile/particle_colour/plant",
                                    "#phantasia:tile/generic/harvest_particle_frequency",
                                ),
                            ),
                        )
                        .setTilePlacement(
                            new TileItemPlacement().setCondition(
                                "#phantasia:tile/placement/condition_plant",
                            ),
                        )
                        .setTileSFX("#phantasia:tile/sfx/foliage"),
                ),
        ),
    ),
];
