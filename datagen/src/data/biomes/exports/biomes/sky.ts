import { DatagenReturnData } from "../../../../lib";
import { Sound } from "../../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeSkyColor,
    BiomeTile,
    BiomeTerrainModifier,
    TileEntry,
} from "../../lib/Biome";

export default [
    // Floating Islands
    new DatagenReturnData(
        "sky/floating_islands.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#87CEEB",
            {
                dawn: new BiomeSkyColor("#371479", "#4d1140"),
                day: new BiomeSkyColor("#87CEEB", "#5F91FE"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#2b243f", "#1e1f2b"),
            },
            {
                dawn: "#374A91",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new BiomeTile(
                    "phantasia:grass_block",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:dirt",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
            },
        )
            .setIsSkyland()
            .setTerrainModifier(new BiomeTerrainModifier(0, 0.5))
            .setMusic([
                new Sound("phantasia:music/ornaments_of_the_sky", 0.7),
                new Sound("phantasia:music/soft_hour", 0.6),
            ])
            .setCreatures([])
            .setFoliage([])
            .setStructures([]),
    ),
];
