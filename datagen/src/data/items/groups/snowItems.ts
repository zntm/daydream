import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Item } from "../lib/Item";
import { ItemType } from "../lib/ItemType";
import {
    TileItemHarvest,
    TileItemParticle,
    TileItemProperties,
} from "../lib/TileItem";
import blockWallItems from "./blockWallItems";

export default [
    new DatagenReturnData(
        `generated/data/items/snowball.json`,
        new Item(
            ItemType.Default,
            "phantasia:item/snowball",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    blockWallItems(
        "snow_block",
        [
            TileItemProperties.CanFlip,
            TileItemProperties.CanMirror,
            TileItemProperties.IsTile,
        ],
        new TileItemHarvest(
            0.36,
            0,
            new TileItemParticle(
                "#phantasia:tile/particle_colour/dirt",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/dirt",
        0.15,
        0.05,
    ),
    blockWallItems(
        "snow_bricks",
        [
            TileItemProperties.CanFlip,
            TileItemProperties.CanMirror,
            TileItemProperties.IsTile,
        ],
        new TileItemHarvest(
            0.36,
            0,
            new TileItemParticle(
                "#phantasia:tile/particle_colour/dirt",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/dirt",
        0.15,
        0.05,
    ),
];
