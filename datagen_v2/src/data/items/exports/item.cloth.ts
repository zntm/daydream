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
    "black",
    "blue",
    "brown",
    "cyan",
    "gray",
    "green",
    "light_blue",
    "light_gray",
    "lime",
    "orange",
    "pink",
    "purple",
    "red",
    "white",
    "yellow",
];

export default CLOTH_COLORS.map(
    (color) =>
        new DatagenReturnData(
            `${color}_cloth.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${color}_cloth`,
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
