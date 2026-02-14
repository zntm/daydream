import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Item } from "../lib/Item";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemParticle,
    TileItemProperties,
} from "../lib/TileItem";

export default (
    id: string,
    harvestLevel: number,
    blockProperties: TileItemProperties[],
    blockHarvest: TileItemHarvest,
    blockSFX: string,
    oreProperties: TileItemProperties[],
    oreHarvest: TileItemHarvest,
    oreSFX: string,
    hasRawItem?: boolean,
) => {
    const data = [
        new DatagenReturnData(
            `generated/data/items/${id}.json`,
            new Item(
                ItemType.Default,
                `phantasia:item/${id}`,
                "#phantasia:item/generic/inventory_default",
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_block.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${id}_block`,
                "#phantasia:item/generic/inventory_default",
                blockProperties,
            )
                .setTileDrops([
                    new TileItemDrop(`phantasia:item/${id}_block`).setCondition(
                        new TileItemCondition(
                            "#phantasia:item/type/pickaxe",
                            harvestLevel,
                        ),
                    ),
                ])
                .setTileHarvest(blockHarvest)
                .setTileSFX(blockSFX)
                .setAudioProperties(0.65, 0.5),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_ore.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${id}_ore`,
                "#phantasia:item/generic/inventory_default",
                oreProperties,
            )
                .setTileDrops([
                    new TileItemDrop(`phantasia:item/${id}_ore`).setCondition(
                        new TileItemCondition(
                            "#phantasia:item/type/pickaxe",
                            harvestLevel,
                        ),
                    ),
                ])
                .setTileHarvest(oreHarvest)
                .setTileSFX(oreSFX)
                .setAudioProperties(0.65, 0.5),
        ),
    ];

    if (hasRawItem) {
        data.push(
            new DatagenReturnData(
                `generated/data/items/raw_${id}.json`,
                new Item(
                    ItemType.Default,
                    `phantasia:item/raw_${id}`,
                    "#phantasia:item/generic/inventory_default",
                ),
            ),
        );
    }

    return data;
};
