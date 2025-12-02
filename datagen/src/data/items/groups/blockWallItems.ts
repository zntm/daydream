import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileProperties,
    ItemTileSFX,
} from "../lib/TileItem";

export default (
    id: string,
    properties: ItemTileProperties[],
    harvest: ItemTileHarvest,
    sfx: string,
) => [
        new TileItem(
            ItemType.Solid,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_tile",
            properties,
        )
            .setTileDrops([new ItemTileDrop(`phantasia:${id}`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx),
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}_wall`,
            "#phantasia:item/generic/inventory_tile",
            [...properties, ItemTileProperties.IsWall],
        )
            .setTileDrops([new ItemTileDrop(`phantasia:${id}_wall`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx),
    ];
