import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    TileItemDrop,
    TileItemHarvest,
    TileItemProperties,
} from "../lib/TileItem";

export default (
    id: string,
    properties: TileItemProperties[],
    harvest: TileItemHarvest,
    sfx: string,
    lowpass: number = 0,
    reverb: number = 0,
) => [
    new DatagenReturnData(
        `generated/data/items/${id}.json`,
        new TileItem(
            ItemType.Solid,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_tile",
            properties,
        )
            .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx)
            .setAudioProperties(lowpass, reverb),
    ),
    new DatagenReturnData(
        `generated/data/items/${id}_wall.json`,
        new TileItem(
            ItemType.Untouchable,
            `phantasia:item/${id}_wall`,
            "#phantasia:item/generic/inventory_tile",
            [...properties, TileItemProperties.IsWall],
        )
            .setTileDrops([new TileItemDrop(`phantasia:${id}_wall`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx)
            .setAudioProperties(lowpass, reverb),
    ),
];
