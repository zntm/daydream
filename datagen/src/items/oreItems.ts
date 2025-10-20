import { DatagenReturnData } from "../..";
import { Item, ItemType } from "../items";

const {
    default: tileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileProperties,
    ItemTileSFX,
} = import.meta.require("./tileItem");

export default (
    id: string,
    harvestLevel: number,
    blockProperties: typeof ItemTileProperties,
    blockHarvest: typeof ItemTileHarvest,
    blockSFX: typeof ItemTileSFX,
    oreProperties: typeof ItemTileProperties,
    oreHarvest: typeof ItemTileHarvest,
    oreSFX: typeof ItemTileSFX,
) => [
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

/*
    inventory: string | ItemInventory,
    properties?: ItemTileProperties | ItemTileProperties[],
    drop?: string | ItemTileDrop[],
    harvest?: ItemTileHarvest,
    placement?: string | ItemTilePlacement,
    sfx?: string | ItemTileSFX,*/
