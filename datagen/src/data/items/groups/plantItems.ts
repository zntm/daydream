import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { ItemFunction } from "../lib/ItemFunction";
import {
    TileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileDropCondition,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTilePlacementCondition,
    ItemTilePlacementConditionType,
    ItemTilePlacementConditionValue,
    ItemTileProperties,
    ItemTileSFX,
} from "../lib/TileItem";

export default [
    ...[
        {
            id: "cactus",
            particleColour: ["#113402", "#032802"],
        },
        {
            id: "cattail",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new ItemTileDropCondition().setIndex(2),
        },
        {
            id: "sunflower",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new ItemTileDropCondition().setIndex(0),
        },
    ].map(
        ({ id, particleColour, dropCondition }) =>
            new DatagenReturnData(
                `generated/data/items/${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [ItemTileProperties.CanMirror],
                )
                    .setTileDrops([
                        new ItemTileDrop(`phantasia:${id}`).setCondition(
                            dropCondition,
                        ),
                    ])
                    .setTileHarvest(
                        new ItemTileHarvest(
                            0.38,
                            0,
                            new ItemTileParticle(
                                particleColour,
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                        ),
                    )
                    .setTilePlacement(
                        new ItemTilePlacement().setCondition(
                            new ItemTilePlacementCondition(
                                ItemTilePlacementConditionType.Every,
                                [
                                    {
                                        condition:
                                            new ItemTilePlacementCondition(
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
                    .setTileSFX("#phantasia:tile/sfx/foliage")
                    .setAudioProperties(0.05, 0.0),
            ),
    ),
    new DatagenReturnData(
        "generated/data/items/cactus_flower.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/cactus_flower",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.IsFoliage],
        )
            .setTileDrops([new ItemTileDrop("phantasia:cactus_flower")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.38,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new ItemTilePlacement().setCondition(
                    "#phantasia:tile/placement/condition_dry_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setAudioProperties(0.05, 0.0),
    ),
    new DatagenReturnData(
        "generated/data/items/dead_bush.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/dead_bush",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
        )
            .setTileDrops([new ItemTileDrop("phantasia:twig")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.38,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new ItemTilePlacement().setCondition(
                    "#phantasia:tile/placement/condition_dry_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.05, 0.0),
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
    ].map(
        (id: string) =>
            new DatagenReturnData(
                `generated/data/items/${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [
                        ItemTileProperties.CanMirror,
                        ItemTileProperties.IsFoliage,
                    ],
                )
                    .setTileDrops([new ItemTileDrop(`phantasia:${id}`)])
                    .setTileHarvest(
                        new ItemTileHarvest(
                            0.38,
                            0,
                            new ItemTileParticle(
                                "#phantasia:tile/particle_colour/plant",
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                        ),
                    )
                    .setTilePlacement(
                        new ItemTilePlacement().setCondition(
                            "#phantasia:tile/placement/condition_plant",
                        ),
                    )
                    .setTileSFX("#phantasia:tile/sfx/foliage")
                    .setAudioProperties(0.05, 0.0),
            ),
    ),
    new DatagenReturnData(
        "generated/data/items/seeding_dandelion.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/seeding_dandelion",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
        )
            .setTileDrops([new ItemTileDrop("phantasia:seeding_dandelion")])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.38,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/plant",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTilePlacement(
                new ItemTilePlacement().setCondition(
                    "#phantasia:tile/placement/condition_plant",
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setAudioProperties(0.05, 0.0)
            .addOnRandomTick([
                new ItemFunction("phantasia:spawn_particle", {
                    id: "phantasia:tile/seeding_dandelion",
                }),
            ]),
    ),
];
