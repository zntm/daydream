import { TileItemPlacementConditionType } from "../../../../../datagen/src/data/items/lib";
import { DatagenReturnData } from "../../../lib";
import { ItemType, ItemParticle, TileItemProperties } from "../lib";
import { TileItem, TileItemAudioProperties, TileItemDrop, TileItemHarvest, TileItemPlacement, TileItemPlacementCondition, TileItemPlacementConditionValue } from "../lib/TileItem";

export default [
    "algae",
    "duckweed",
    "sargassum",
].map((id) => new DatagenReturnData(
    `${id}.json`,
    new TileItem(
        ItemType.Untouchable,
        `phantasia:item/${id}`,
        "#phantasia:item/generic/inventory_default",
        [TileItemProperties.CanMirror],
    )
        .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
        .setTileHarvest(
            new TileItemHarvest(
                0.38,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/twig",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
        )
        .setTilePlacement(
            new TileItemPlacement().setCondition(
                new TileItemPlacementCondition(TileItemPlacementConditionType.Every, [
                    new TileItemPlacementConditionValue(0, 1, "liquid")
                ]),
            ),
        )
        .setTileSFX("#phantasia:tile/sfx/foliage")
        .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
),)