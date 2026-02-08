import { DatagenReturnData } from "../../../../lib";
import {
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    TileItemProperties,
} from "../index";

export default (
    id: string,
    properties: TileItemProperties[],
    harvest: TileItemHarvest,
    sfx: string,
    lowpass: number = 0,
    reverb: number = 0,
) => [
        new DatagenReturnData(
            `${id}.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${id}`,
                "#phantasia:item/generic/inventory_tile",
                properties,
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
                .setTileHarvest(harvest)
                .setTileSFX(sfx)
                .setTileAudioProperties(new TileItemAudioProperties(lowpass, reverb)),
        ),
        new DatagenReturnData(
            `${id}_wall.json`,
            new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}_wall`,
                "#phantasia:item/generic/inventory_tile",
                [...properties, TileItemProperties.IsWall],
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}_wall`)])
                .setTileHarvest(harvest)
                .setTileSFX(sfx)
                .setTileAudioProperties(new TileItemAudioProperties(lowpass, reverb)),
        ),
    ];
