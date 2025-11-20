import { ItemType } from "./lib/ItemType";
import tileItem, {
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
} from "./tileItem";

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
    ].map(({ id, particleColour, dropCondition }) =>
        tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror],
            [new ItemTileDrop(id).setCondition(dropCondition)],
            new ItemTileHarvest(
                0.38,
                0,
                new ItemTileParticle(
                    particleColour,
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
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
                                        "default",
                                    ).setId("$ID"),
                                ],
                            ),
                        },
                        new ItemTilePlacementConditionValue(0, -1, "z").setId([
                            "$EMPTY",
                            "$ID",
                        ]),
                    ],
                ),
            ),
            "#phantasia:tile/sfx/foliage",
        ),
    ),
    tileItem(
        "cactus_flower",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.IsFoliage],
        [new ItemTileDrop("phantasia:cactus_flower")],
        new ItemTileHarvest(
            0.38,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setCondition(
            "#phantasia:tile/placement/condition_dry_plant",
        ),
        "#phantasia:tile/sfx/foliage",
    ),
    tileItem(
        "dead_bush",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
        [new ItemTileDrop("phantasia:twig")],
        new ItemTileHarvest(
            0.38,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setCondition(
            "#phantasia:tile/placement/condition_dry_plant",
        ),
        "#phantasia:tile/sfx/wood",
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
    ].map((id: string) =>
        tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
            [new ItemTileDrop(`phantasia:${id}`)],
            new ItemTileHarvest(
                0.38,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/plant",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            new ItemTilePlacement().setCondition(
                "#phantasia:tile/placement/condition_plant",
            ),
            "#phantasia:tile/sfx/foliage",
        ),
    ),
];
