import { DatagenReturnData, Sound, ColorGradient } from "../../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeTile,
    BiomeFoliage,
    BiomeStructure,
    TileEntry,
} from "../../lib/Biome";

const CAVE_SKY = new ColorGradient([
    { position: 0.15, color: "#180738" }, // Dawn
    { position: 0.45, color: "#5F91FE" }, // Day
    { position: 0.72, color: "#C4502D" }, // Dusk
    { position: 0.90, color: "#000019" }, // Night
]);

const CAVE_LIGHT = new ColorGradient([
    { position: 0.15, color: "#374A91" },
    { position: 0.45, color: "#FFFFFF" },
    { position: 0.72, color: "#C68B69" },
    { position: 0.90, color: "#141B35" },
]);

// Helper for nightrock tiles
const TILES_NIGHTROCK = {
    top_layer: new BiomeTile(
        "phantasia:nightrock",
        [
            new TileEntry("phantasia:nightrock_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
    middle_layer: new BiomeTile(
        "phantasia:nightrock",
        [
            new TileEntry("phantasia:nightrock_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
    bottom_layer: new BiomeTile(
        "phantasia:nightrock",
        [
            new TileEntry("phantasia:nightrock_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
};

const TILES_STONE = {
    top_layer: new BiomeTile(
        "phantasia:stone",
        [
            new TileEntry("phantasia:stone_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
    middle_layer: new BiomeTile(
        "phantasia:stone",
        [
            new TileEntry("phantasia:stone_wall", 4),
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
};

export default [
    // Chasm
    new DatagenReturnData(
        "cave/chasm.json",
        new Biome(
            new BiomeBackground("phantasia:background/chasm", 0.7),
            "#000000",
            CAVE_SKY,
            CAVE_LIGHT,
            TILES_STONE,
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/behind", 0.5),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.07).setGenerateOn([
                    "phantasia:stone",
                ]),
                new BiomeFoliage("phantasia:twig", 0.0007).setGenerateOn([
                    "phantasia:stone",
                ]),
                new BiomeFoliage("phantasia:cave_roots", 0.04).setGenerateOn([
                    "phantasia:stone",
                ]),
            ])
            .setStructures([
                new BiomeStructure("phantasia:ore/coal", 0.003).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/copper", 0.003).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(
                    640,
                    768,
                ),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(
                    712,
                    768,
                ),
            ]),
    ),
    // Depths
    new DatagenReturnData(
        "cave/depths.json",
        new Biome(
            new BiomeBackground("phantasia:background/depths", 0.7),
            "#000000",
            CAVE_SKY,
            CAVE_LIGHT,
            TILES_NIGHTROCK,
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.7),
                new Sound("phantasia:music/behind", 0.6),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.07).setGenerateOn([
                    "phantasia:stone",
                ]),
                new BiomeFoliage("phantasia:twig", 0.0007).setGenerateOn([
                    "phantasia:stone",
                ]),
                new BiomeFoliage("phantasia:cave_roots", 0.04).setGenerateOn([
                    "phantasia:stone",
                ]),
            ])
            .setStructures([
                new BiomeStructure("phantasia:ore/coal", 0.003).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/copper", 0.003).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(
                    640,
                    768,
                ),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(
                    712,
                    768,
                ),
            ]),
    ),
];
