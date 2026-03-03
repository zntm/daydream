import {
    DatagenReturnData,
    Sound,
    ColorGradient,
    ColorGradientPoint,
    SmartValue,
    SmartValueChooseWeightedOption as ChooseWeightedOption,
} from "../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeTile,
    BiomeFoliage,
    BiomeStructure,
    TileEntry,
} from "../lib/Biome";

const CAVE_SKY = new ColorGradient([
    new ColorGradientPoint(0.15, "#180738"),
    new ColorGradientPoint(0.45, "#5F91FE"),
    new ColorGradientPoint(0.72, "#C4502D"),
    new ColorGradientPoint(0.9, "#000019"),
]);

const CAVE_LIGHT = new ColorGradient([
    new ColorGradientPoint(0.15, "#374A91"),
    new ColorGradientPoint(0.45, "#FFFFFF"),
    new ColorGradientPoint(0.72, "#C68B69"),
    new ColorGradientPoint(0.9, "#141B35"),
]);

// Helper for nightrock tiles
const TILES_NIGHTROCK = {
    top_layer: new BiomeTile("phantasia:nightrock", [
        new TileEntry("phantasia:nightrock_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:nightrock", [
        new TileEntry("phantasia:nightrock_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:nightrock", [
        new TileEntry("phantasia:nightrock_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
};

const TILES_STONE = {
    top_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
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
    new ColorGradientPoint(0.15, "#0A1628"),
    new ColorGradientPoint(0.45, "#2A4A7A"),
    new ColorGradientPoint(0.72, "#1A3058"),
    new ColorGradientPoint(0.9, "#050A14"),
]);

const MOONFALL_LIGHT = new ColorGradient([
    new ColorGradientPoint(0.15, "#1B2A4A"),
    new ColorGradientPoint(0.45, "#7BA8D4"),
    new ColorGradientPoint(0.72, "#3D5A8E"),
    new ColorGradientPoint(0.9, "#0D1526"),
]);

export default [
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
                new BiomeFoliage("phantasia:lumin_blossom", 0.08).setGenerateOn(
                    ["phantasia:lumin_moss", "phantasia:petrilumin"],
                ),
            ])
            .setStructures([
                new BiomeStructure(
                    "phantasia:tall_foliage/lumin_vine",
                    0.05,
                ),
            ]),
    ),
];
