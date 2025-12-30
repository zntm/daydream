import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { ItemScript } from "../lib/ProgLang";
import {
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemDropCondition,
    TileItemHarvest,
    TileItemParticle,
    TileItemPlacement,
    TileItemPlacementCondition,
    TileItemPlacementConditionType,
    TileItemPlacementConditionValue,
    TileItemProperties,
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
            dropCondition: new TileItemDropCondition().setIndex(2),
        },
        {
            id: "sunflower",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new TileItemDropCondition().setIndex(0),
        },
    ].map(
        ({ id, particleColour, dropCondition }) =>
            new DatagenReturnData(
                `generated/data/items/${id}.json`,
                new TileItem(
                    ItemType.Untouchable,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.CanMirror],
                )
                    .setTileDrops([
                        new TileItemDrop(`phantasia:${id}`).setCondition(
                            dropCondition,
                        ),
                    ])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.38,
                            0,
                            new TileItemParticle(
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
                                    {
                                        condition:
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
            [TileItemProperties.IsFoliage],
        )
            .setTileDrops([new TileItemDrop("phantasia:cactus_flower")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new TileItemParticle(
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
            .setAudioProperties(0.05, 0.0),
    ),
    new DatagenReturnData(
        "generated/data/items/dead_bush.json",
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
                    new TileItemParticle(
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
                        TileItemProperties.CanMirror,
                        TileItemProperties.IsFoliage,
                    ],
                )
                    .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.38,
                            0,
                            new TileItemParticle(
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
                    .setAudioProperties(0.05, 0.0),
            ),
    ),
    new DatagenReturnData(
        "generated/data/items/seeding_dandelion.json",
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
                    new TileItemParticle(
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
            .setAudioProperties(0.05, 0.0)
            .addOnRandomTick([
                new ItemScript("items/spawn_particle", {
                    id: "phantasia:tile/seeding_dandelion",
                }),
            ]),
    ),
];
