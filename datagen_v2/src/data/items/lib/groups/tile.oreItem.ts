import { DatagenReturnData } from "../../../../lib";
import type { ItemPropertiesType } from "../ItemProperties";
import { ItemType } from "../ItemType";
import { ItemSFX } from "../ItemSFX";
import { Item } from "../Item";
import {
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
} from "../TileItem";

export default (
    namespace: string,
    id: string,
    harvestLevel: number,
    blockProperties: ItemPropertiesType[],
    blockHarvest: TileItemHarvest,
    blockSFX: string | ItemSFX,
    oreProperties: ItemPropertiesType[],
    oreHarvest: TileItemHarvest,
    oreSFX: string | ItemSFX,
    hasRawItem?: boolean,
) => {
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
                blockProperties,
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
                .setTileHarvest(blockHarvest)
                .setTileSFX(blockSFX)
                .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
        ),
        new DatagenReturnData(
            `${id}_ore.json`,
            new TileItem(
                ItemType.Solid,
                `${namespace}:item/${id}_ore`,
                "#phantasia:item/generic/inventory_default",
                oreProperties,
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
                .setTileHarvest(oreHarvest)
                .setTileSFX(oreSFX)
                .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
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
};
