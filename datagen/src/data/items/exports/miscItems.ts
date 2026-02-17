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
import { ArrowItem } from "../lib/ArrowItem";

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
        "silk.json",
        new Item(
            ItemType.Default,
            "phantasia:item/silk",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    new DatagenReturnData(
        "arrow.json",
        new ArrowItem("phantasia:item/arrow", 2)
            .setProjectile("phantasia:arrow"),
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
    new DatagenReturnData(
        "anvil.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/anvil",
            "#phantasia:item/generic/inventory_tile",
            [TileItemProperties.IsCraftingStation],
        )
            .setTileDrops([new TileItemDrop("phantasia:anvil")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.36,
                    1,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/pickaxe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.4, 0.1)),
    ),
    new DatagenReturnData(
        "rope.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/rope",
            "#phantasia:item/generic/inventory_tile",
            [TileItemProperties.IsFoliage],
        )
            .setTileDrops([new TileItemDrop("phantasia:rope")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.24,
                    0,
                    new ItemParticle(
                        "#8B5A2B",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/foliage")
            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
    ),
];
