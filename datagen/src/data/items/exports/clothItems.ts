import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";

const CLOTH_COLORS = [
    "black_cloth",
    "blue_cloth",
    "brown_cloth",
    "cyan_cloth",
    "gray_cloth",
    "green_cloth",
    "light_blue_cloth",
    "light_gray_cloth",
    "lime_cloth",
    "orange_cloth",
    "pink_cloth",
    "purple_cloth",
    "red_cloth",
    "white_cloth",
    "yellow_cloth",
];

export default CLOTH_COLORS.map(
    (color) =>
        new DatagenReturnData(
            `${color}.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${color}`,
                "#phantasia:item/generic/inventory_tile",
                [
                    TileItemProperties.CanFlip,
                    TileItemProperties.CanMirror,
                    TileItemProperties.IsTile,
                ],
            )
                .setTileHarvest(
                    new TileItemHarvest(
                        0.2,
                        0,
                        new ItemParticle(
                            "#phantasia:tile/particle_colour/white",
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                    ),
                )
                .setTileSFX("#phantasia:tile/sfx/flesh")
                .setTileAudioProperties(new TileItemAudioProperties(0.1, 0.05)),
        ),
);

