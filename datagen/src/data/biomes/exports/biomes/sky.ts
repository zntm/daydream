import { DatagenReturnData, Sound, ColorGradient } from "../../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeTile,
    BiomeTerrainModifier,
    TileEntry,
} from "../../lib/Biome";

const SKYZEN_SKY = new ColorGradient([
    { position: 0.15, color: "#371479" }, // Dawn
    { position: 0.45, color: "#87CEEB" }, // Day
    { position: 0.72, color: "#C4502D" }, // Dusk
    { position: 0.90, color: "#2b243f" }, // Night
]);

const SKYZEN_LIGHT = new ColorGradient([
    { position: 0.15, color: "#374A91" },
    { position: 0.45, color: "#FFFFFF" },
    { position: 0.72, color: "#C68B69" },
    { position: 0.90, color: "#141B35" },
]);

export default [
    // Floating Islands
    new DatagenReturnData(
        "sky/floating_islands.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#87CEEB",
            SKYZEN_SKY,
            SKYZEN_LIGHT,
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
