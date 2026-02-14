import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemScript } from "../lib/ProgLang";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemParticle,
    TileItemPlacement,
    TileItemPlacementCondition,
    TileItemPlacementConditionType,
    TileItemPlacementConditionValue,
    TileItemProperties,
} from "../lib/TileItem";
import { ToolItem } from "../lib/ToolItem";

const { default: blockWallItems } = import.meta.require("./blockWallItems");

export default (
    id: string,
    leavesParticleId: string | string[],
    logParticleId: string | string[],
    plankParticleId: string | string[],
) => [
    new DatagenReturnData(
        `generated/data/items/${id}.json`,
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
                    new TileItemParticle(
                        logParticleId,
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
            .setAudioProperties(0.4, 0.1),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_chest.json`,
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
                    new TileItemParticle(
                        plankParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.4, 0.1),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_leaves.json`,
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
            // .setTileDrops([new TileItemDrop(`phantasia:${id}_leaves`)])
            .setTileHarvest(
                new TileItemHarvest(
                    0.44,
                    1,
                    new TileItemParticle(
                        leavesParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.2, 0.0)
            .addOnRandomTick([
                new ItemScript("tile/leaf_decay", {
                    particle: leavesParticleId,
                }, 0.03),
            ]),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_pickaxe.json`,
        new ToolItem(
            `${id}_pickaxe`,
            73,
            "#phantasia:item/generic/durability_bar",
            undefined,
            1,
            1,
        ),
    ),
    ...blockWallItems(
        `${id}_planks`,
        [TileItemProperties.IsTile],
        new TileItemHarvest(
            0.44,
            1,
            new TileItemParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/axe"),
        ),
        "#phantasia:tile/sfx/wood",
        0.4,
        0.1,
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_shovel.json`,
        new ToolItem(
            `${id}_shovel`,
            65,
            "#phantasia:item/generic/durability_bar",
            undefined,
            1,
            1,
        ),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_workbench.json`,
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
                    new TileItemParticle(
                        plankParticleId,
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.4, 0.1),
    ),
];
