import { DatagenReturnData } from "../../../../lib";
import { TileItemProperties } from "../ItemProperties";
import { ItemSFX } from "../ItemSFX";
import { ItemType } from "../ItemType";
import {
    TileItem,
    TileItemDrop,
    TileItemHarvest,
    type TileItemAudioProperties,
} from "../TileItem";

export default (
    namespace: string,
    id: string,
    properties: TileItemProperties[],
    harvest: TileItemHarvest,
    sfx: string | ItemSFX,
    audioProperties: TileItemAudioProperties,
) => [
    new DatagenReturnData(
        `${id}.json`,
        new TileItem(
            ItemType.Solid,
            `${namespace}:/item/${id}`,
            "#phantasia:item/generic/inventory_tile",
            properties,
        )
            .setTileAudioProperties(audioProperties)
            .setTileDrops([new TileItemDrop(`${namespace}:${id}`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx),
    ),
    new DatagenReturnData(
        `${id}_wall.json`,
        new TileItem(
            ItemType.Solid,
            `${namespace}:/item/${id}_wall`,
            "#phantasia:item/generic/inventory_tile",
            [...properties, TileItemProperties.IsWall],
        )
            .setTileAudioProperties(audioProperties)
            .setTileDrops([new TileItemDrop(`${namespace}:${id}_wall`)])
            .setTileHarvest(harvest)
            .setTileSFX(sfx),
    ),
];
