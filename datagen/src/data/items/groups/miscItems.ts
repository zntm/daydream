import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Item } from "../lib/Item";
import { ItemType } from "../lib/ItemType";
import {
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemParticle,
    TileItemProperties,
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
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
        )
            .setTileDrops([
                new TileItemDrop(`phantasia:sand`).setCondition(
                    new TileItemCondition("#phantasia:item/type/shovel", 0),
                ),
            ])
            .setTileHarvest(
                new TileItemHarvest(
                    0.36,
                    0,
                    new TileItemParticle(
                        "#phantasia:tile/particle_colour/sand",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/sand")
            .setAudioProperties(0.2, 0.0),
    ),
];
