import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Item } from "./lib/Item";
import { ItemType } from "./lib/ItemType";
import type {
    ItemTileCondition as ItemTileConditionType,
    ItemTileDrop as ItemTileDropType,
    ItemTileHarvest as ItemTileHarvestType,
    ItemTileParticle as ItemTileParticleType,
    ItemTileProperties,
    ItemTileSFX as ItemTileSFXType,
} from "./tileItem";

const {
    default: tileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileSFX,
} = import.meta.require("./tileItem");

export default (
    id: string,
    harvestLevel: number,
    blockProperties: ItemTileProperties[],
    blockHarvest: ItemTileHarvestType,
    blockSFX: ItemTileSFXType,
    oreProperties: ItemTileProperties[],
    oreHarvest: ItemTileHarvestType,
    oreSFX: ItemTileSFXType,
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
        tileItem(
            `${id}_block`,
            ItemType.Solid,
            "#phantasia:item/generic/inventory_default",
            blockProperties,
            [
                new ItemTileDrop(`phantasia:item/${id}_block`).setCondition(
                    new ItemTileCondition(
                        "#phantasia:item/type/pickaxe",
                        harvestLevel,
                    ),
                ),
            ],
            blockHarvest,
            undefined,
            blockSFX,
        ),
        tileItem(
            `${id}_ore`,
            ItemType.Solid,
            "#phantasia:item/generic/inventory_default",
            oreProperties,
            [
                new ItemTileDrop(`phantasia:item/${id}_ore`).setCondition(
                    new ItemTileCondition(
                        "#phantasia:item/type/pickaxe",
                        harvestLevel,
                    ),
                ),
            ],
            oreHarvest,
            undefined,
            oreSFX,
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
