import { DatagenReturnData } from "../../../lib";
import {
    ItemType,
    ItemScript,
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    ItemParticle,
    TileItemPlacement,
    TileItemPlacementCondition,
    TileItemPlacementConditionType,
    TileItemPlacementConditionValue,
    TileItemProperties,
} from "../lib";

export default [
    ...[
        {
            id: "cactus",
            particleColour: ["#113402", "#032802"],
        },
        {
            id: "cattail",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new TileItemCondition("").setIndex(2), // Actually TileItemCondition was used with dropIndex in old code sometimes
        },
        {
            id: "sunflower",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new TileItemCondition("").setIndex(0),
        },
    ].map(
        ({ id, particleColour, dropCondition }) =>
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.CanMirror],
                )
                    .setTileDrops([
                        new TileItemDrop(`phantasia:${id}`).setCondition(
                            dropCondition as any,
                        ),
                    ])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.38,
                            0,
                            new ItemParticle(
                                particleColour,
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
                    .setTileSFX("#phantasia:tile/sfx/foliage")
                    .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
            ),
    ),
    new DatagenReturnData(
        "cactus_flower.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/cactus_flower",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.IsFoliage],
        )
            .setTileDrops([new TileItemDrop("phantasia:cactus_flower")])
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
            .setTileDrops([new TileItemDrop("phantasia:twig")])
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
    ...[
        "bluebells",
        "daisy",
        "dandelion",
        "dendrobium",
        "globeflower",
        "lilybell",
        "orchids",
        "rose",
        "anemone",
        "cave_roots",
    ].map(
        (id: string) =>
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
                    .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
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
                    .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
            ),
    ),
    new DatagenReturnData(
        "bamboo.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/bamboo",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror, TileItemProperties.IsFoliage],
        )
            .setTileDrops([new TileItemDrop("phantasia:bamboo")])
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
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
    ),
    new DatagenReturnData(
        "seeding_dandelion.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/seeding_dandelion",
            "#phantasia:item/generic/inventory_default",
            [TileItemProperties.CanMirror, TileItemProperties.IsFoliage],
        )
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
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0))
            .setTileOnRandomTick([
                new ItemScript("@phantasia:items/spawn_particle", {
                    id: "phantasia:tile/seeding_dandelion",
                }),
            ]),
    ),
];
