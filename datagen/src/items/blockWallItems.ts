import { ItemType } from "../items";
import { ItemTileDrop } from "./tileItem";

const {
    default: tileItem,
    ItemTileHarvest,
    ItemTileProperties,
    ItemTileSFX,
} = import.meta.require("./tileItem");

export default (
    id: string,
    properties: typeof ItemTileProperties,
    harvest: typeof ItemTileHarvest,
    sfx: typeof ItemTileSFX,
) => [
    tileItem(
        id,
        ItemType.Solid,
        "#phantasia:item/generic/inventory_tile",
        properties,
        [new ItemTileDrop(`phantasia:${id}`)],
        harvest,
        undefined,
        sfx,
    ),
    tileItem(
        `${id}_wall`,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        [...properties, ItemTileProperties.IsWall],
        [new ItemTileDrop(`phantasia:${id}_wall`)],
        harvest,
        undefined,
        sfx,
    ),
];
