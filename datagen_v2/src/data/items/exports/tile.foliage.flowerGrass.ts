import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    TileItemPlacement,
    TileItemProperties,
} from "../lib";

export default [
    /* flowers */
    [
        "anemone",
        "bluebells",
        "daisy",
        "daffodil",
        "dandelion",
        "dendrobium",
        "globeflower",
        "lilybell",
        "lumin_blossom",
        "marigold",
        "orchids",
        "petunia",
        "rose",
        "sweet_pea",
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
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.05, 0),
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
                    .setTileSFX("#phantasia:tile/sfx/foliage"),
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
                new ItemScript("@phantasia:items/spawn_particle", {
                    id: "phantasia:tile/seeding_dandelion",
                }),
            ]),
    ),
    /* grass-like */
    ["", "dry", "swamp", "taiga"]
        .map((variant) => {
            const id = variant !== "" ? `grass_${variant}` : "grass";

            return [`short_${id}`, `tall_${id}`];
        })
        .flat()
        .concat(["cave_roots", "lumin_sprouts"])
        .map(
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
                        .setTileAudioProperties(
                            new TileItemAudioProperties(0.05, 0.0),
                        ),
                ),
        ),
];
