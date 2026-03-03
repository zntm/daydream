import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
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
    /* tall foliage */
    ...[
        {
            id: "cactus",
            particleColour: ["#113402", "#032802"],
        },
        {
            id: "cattail",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new TileItemCondition("").setIndex(2),
        },
        {
            id: "sunflower",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new TileItemCondition("").setIndex(0),
        },
        {
            id: "bamboo",
            particleColour: "#phantasia:tile/particle_colour/plant",
        },
    ].map(
        ({ id, particleColour, dropCondition }) =>
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
                                particleColour as any,
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
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.05, 0.0),
                    ),
            ),
    ),
];
