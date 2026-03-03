import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
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
        "seeding_dandelion",
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
    /* grass-like */
    ["dry", "swampy", "boreal"]
        .map((i) => {
            return [`tall_${i}_grass`, `short_${i}_grass`];
        })
        .flat()
        .concat(["cave_roots", "lumin_sprouts", "short_grass", "tall_grass"])
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
];
