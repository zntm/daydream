import { DatagenReturnData } from "../../../lib";
import {
    Item,
    ItemType,
    TileItemHarvest,
    ItemParticle,
    TileItemProperties,
} from "../lib";
import blockWallItems from "../lib/groups/tile.blockWall";

export default [
    new DatagenReturnData(
        `snowball.json`,
        new Item(
            ItemType.Default,
            "phantasia:item/snowball",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    ...blockWallItems(
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
        0.15,
        0.05,
    ),
    ...blockWallItems(
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
        0.15,
        0.05,
    ),
];
