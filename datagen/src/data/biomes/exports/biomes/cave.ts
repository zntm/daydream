import { DatagenReturnData, Sound, ColorGradient, SmartValue, ChooseWeightedOption } from "../../../../lib";

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

const TILES_GRIMSTONE = {
    top_layer: new BiomeTile(
        "phantasia:grimstone",
        [
            new TileEntry("phantasia:grimstone_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
    middle_layer: new BiomeTile(
        "phantasia:grimstone",
        [
            new TileEntry("phantasia:grimstone_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
    bottom_layer: new BiomeTile(
        "phantasia:grimstone",
        [
            new TileEntry("phantasia:grimstone_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
};

const TILES_WILDROOTS = {
    top_layer: new BiomeTile(
        "phantasia:moss",
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
        "phantasia:dirt",
        [
            new TileEntry("phantasia:dirt_wall", 4),
            new TileEntry("$EMPTY", 1),
        ],
    ),
};

const MOONFALL_LAYER = (base: TileEntry[], wall: TileEntry[]) =>
    new BiomeTile(base, wall);

const MOONFALL_BASE = [
    new TileEntry("phantasia:petrilumin", 1).setNoiseRange(0, 60),
    new TileEntry(
        SmartValue.ChooseWeighted([
            new ChooseWeightedOption("phantasia:lumin_moss", 99),
            new ChooseWeightedOption("phantasia:lumin_bulb", 1),
        ]),
        4,
    ).setNoiseRange(60, 256),
];

const MOONFALL_WALL = [
    new TileEntry("phantasia:petrilumin_wall", 1).setNoiseRange(0, 60),
    new TileEntry("phantasia:lumin_moss_wall", 4).setNoiseRange(60, 252),
    new TileEntry("$EMPTY", 1).setNoiseRange(252, 256),
];

const TILES_MOONFALL = {
    top_layer: MOONFALL_LAYER(MOONFALL_BASE, MOONFALL_WALL),
    middle_layer: MOONFALL_LAYER(MOONFALL_BASE, MOONFALL_WALL),
    bottom_layer: MOONFALL_LAYER(MOONFALL_BASE, MOONFALL_WALL),
};

const MOONFALL_SKY = new ColorGradient([
    { position: 0.15, color: "#0A1628" },
    { position: 0.45, color: "#2A4A7A" },
    { position: 0.72, color: "#1A3058" },
    { position: 0.90, color: "#050A14" },
]);

const MOONFALL_LIGHT = new ColorGradient([
    { position: 0.15, color: "#1B2A4A" },
    { position: 0.45, color: "#7BA8D4" },
    { position: 0.72, color: "#3D5A8E" },
    { position: 0.90, color: "#0D1526" },
]);

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
    // Moonfall (Lumin cave region)
    new DatagenReturnData(
        "cave/moonfall.json",
        new Biome(
            new BiomeBackground("phantasia:background/chasm", 0.7),
            "#1B4A3A",
            MOONFALL_SKY,
            MOONFALL_LIGHT,
            TILES_MOONFALL,
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.7),
                new Sound("phantasia:music/behind", 0.6),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:lumin_sprouts", 0.3).setGenerateOn([
                    "phantasia:lumin_moss",
                    "phantasia:petrilumin",
                ]),
                new BiomeFoliage("phantasia:lumin_blossom", 0.08).setGenerateOn([
                    "phantasia:lumin_moss",
                    "phantasia:petrilumin",
                ]),
            ]),
    ),
    // Wiltens (Mausoline cave region)
    new DatagenReturnData(
        "cave/wiltens.json",
        new Biome(
            new BiomeBackground("phantasia:background/chasm", 0.7),
            "#1a1625",
            CAVE_SKY,
            CAVE_LIGHT,
            TILES_GRIMSTONE,
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/behind", 0.5),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.07).setGenerateOn([
                    "phantasia:grimstone",
                ]),
                new BiomeFoliage("phantasia:twig", 0.0007).setGenerateOn([
                    "phantasia:grimstone",
                ]),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tall_foliage/vine", 0.01),
                new BiomeStructure("phantasia:ore/coal", 0.003).setRange(0, 768),
                new BiomeStructure("phantasia:ore/copper", 0.003).setRange(0, 768),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(640, 768),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(712, 768),
            ]),
    ),
    // Wildroots (Verdance cave region)
    new DatagenReturnData(
        "cave/wildroots.json",
        new Biome(
            new BiomeBackground("phantasia:background/chasm", 0.7),
            "#2A3C24",
            CAVE_SKY,
            CAVE_LIGHT,
            TILES_WILDROOTS,
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/behind", 0.5),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn([
                    "phantasia:dirt",
                    "phantasia:moss",
                ]),
                new BiomeFoliage("phantasia:twig", 0.001).setGenerateOn([
                    "phantasia:dirt",
                    "phantasia:moss",
                ]),
                new BiomeFoliage("phantasia:bush", 0.05).setGenerateOn([
                    "phantasia:moss",
                ]),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tall_foliage/vine", 0.15),
                new BiomeStructure("phantasia:ore/coal", 0.003).setRange(0, 768),
                new BiomeStructure("phantasia:ore/copper", 0.003).setRange(0, 768),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(640, 768),
                new BiomeStructure("phantasia:ore/iron", 0.003).setRange(712, 768),
            ]),
    ),
];
