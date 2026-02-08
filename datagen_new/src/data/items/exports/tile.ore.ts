import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemParticle,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";
import { oreRegistries } from "../registries";

export default oreRegistries.map(
    ({
        namespace,
        id,
        harvestLevel,
        blockHardness,
        oreHardness,
        particles,
        hasRawItem,
    }) => {
        const data = [
            new DatagenReturnData(
                `${id}.json`,
                new Item(
                    ItemType.Default,
                    `${namespace}:item/${id}`,
                    "#phantasia:item/generic/inventory_default",
                ),
            ),
            new DatagenReturnData(
                `${id}_block.json`,
                new TileItem(
                    ItemType.Solid,
                    `${namespace}:item/${id}_block`,
                    "#phantasia:item/generic/inventory_default",
                    [TileItemProperties.IsTile],
                )
                    .setTileDrops([
                        new TileItemDrop(
                            `${namespace}:item/${id}_block`,
                        ).setCondition(
                            new TileItemCondition(
                                "#phantasia:item/type/pickaxe",
                                harvestLevel,
                            ),
                        ),
                    ])
                    .setTileHarvest(
                        new TileItemHarvest(
                            blockHardness,
                            1,
                            new ItemParticle(
                                particles,
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                            new TileItemCondition(
                                "#phantasia:item/type/pickaxe",
                            ),
                        ),
                    )
                    .setTileSFX("#phantasia:tile/sfx/stone")
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.65, 0.5),
                    ),
            ),
            new DatagenReturnData(
                `${id}_ore.json`,
                new TileItem(
                    ItemType.Solid,
                    `${namespace}:item/${id}_ore`,
                    "#phantasia:item/generic/inventory_default",
                    [
                        TileItemProperties.CanFlip,
                        TileItemProperties.CanMirror,
                        TileItemProperties.IsTile,
                    ],
                )
                    .setTileDrops([
                        new TileItemDrop(
                            `${namespace}:item/${id}_ore`,
                        ).setCondition(
                            new TileItemCondition(
                                "#phantasia:item/type/pickaxe",
                                harvestLevel,
                            ),
                        ),
                    ])
                    .setTileHarvest(
                        new TileItemHarvest(
                            oreHardness,
                            0,
                            new ItemParticle(
                                particles,
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                            new TileItemCondition(
                                "#phantasia:item/type/pickaxe",
                            ),
                        ),
                    )
                    .setTileSFX("#phantasia:tile/sfx/stone")
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.65, 0.5),
                    ),
            ),
        ];

        if (hasRawItem) {
            data.push(
                new DatagenReturnData(
                    `raw_${id}.json`,
                    new Item(
                        ItemType.Default,
                        `${namespace}:item/raw_${id}`,
                        "#phantasia:item/generic/inventory_default",
                    ),
                ),
            );
        }

        return data;
    },
);
