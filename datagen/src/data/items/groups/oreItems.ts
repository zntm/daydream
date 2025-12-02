import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Item } from "../lib/Item";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileProperties,
    ItemTileSFX,
} from "../lib/TileItem";

export default (
    id: string,
    harvestLevel: number,
    blockProperties: ItemTileProperties[],
    blockHarvest: ItemTileHarvest,
    blockSFX: string,
    oreProperties: ItemTileProperties[],
    oreHarvest: ItemTileHarvest,
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
                    new ItemTileDrop(`phantasia:item/${id}_block`).setCondition(
                        new ItemTileCondition(
                            "#phantasia:item/type/pickaxe",
                            harvestLevel,
                        ),
                    ),
                ])
                .setTileHarvest(blockHarvest)
                .setTileSFX(blockSFX),
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
                    new ItemTileDrop(`phantasia:item/${id}_ore`).setCondition(
                        new ItemTileCondition(
                            "#phantasia:item/type/pickaxe",
                            harvestLevel,
                        ),
                    ),
                ])
                .setTileHarvest(oreHarvest)
                .setTileSFX(oreSFX),
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
