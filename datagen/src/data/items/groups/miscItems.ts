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
} from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    new DatagenReturnData(
        "generated/data/items/sand.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/sand",
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanFlip, ItemTileProperties.CanMirror, ItemTileProperties.IsTile],
        )
            .setTileDrops([
                new ItemTileDrop(`phantasia:sand`).setCondition(
                    new ItemTileCondition(
                        "#phantasia:item/type/shovel",
                        0,
                    ),
                ),
            ])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.36,
                    0,
                    new ItemTileParticle(
                        "#phantasia:tile/particle_colour/sand",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/sand")
            .setAudioProperties(0.2, 0.0),
    ),
];
