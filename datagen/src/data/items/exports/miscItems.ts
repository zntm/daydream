import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    ItemParticle,
    TileItemProperties,
} from "../lib";

export default [
    new DatagenReturnData(
        "feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    new DatagenReturnData(
        "sand.json",
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
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/sand",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/sand")
            .setTileAudioProperties(new TileItemAudioProperties(0.2, 0.0)),
    ),
];
