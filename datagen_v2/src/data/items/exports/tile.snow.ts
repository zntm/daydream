import { DatagenReturnData } from "../../../lib";
import { Item, ItemType, ItemParticle, TileItemProperties } from "../lib";
import { TileItemAudioProperties, TileItemHarvest } from "../lib/TileItem";
import { tileBlockWallItems } from "../lib/groups";

export default [
    new DatagenReturnData(
        `snowball.json`,
        new Item(
            ItemType.Default,
            "phantasia:item/snowball",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    tileBlockWallItems(
        "phantasia",
        "snow_block",
        [
            TileItemProperties.CanFlip,
            TileItemProperties.CanMirror,
            TileItemProperties.IsTile,
        ],
        new TileItemHarvest(
            0.36,
            0,
            new ItemParticle(
                "#phantasia:tile/particle_colour/dirt",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/dirt",
        new TileItemAudioProperties(0.15, 0.05),
    ),
    tileBlockWallItems(
        "phantasia",
        "snow_bricks",
        [
            TileItemProperties.CanFlip,
            TileItemProperties.CanMirror,
            TileItemProperties.IsTile,
        ],
        new TileItemHarvest(
            0.36,
            0,
            new ItemParticle(
                "#phantasia:tile/particle_colour/dirt",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/dirt",
        new TileItemAudioProperties(0.15, 0.05),
    ),
];
