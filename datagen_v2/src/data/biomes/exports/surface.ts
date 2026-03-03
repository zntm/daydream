import {
    DatagenReturnData,
    Sound,
    ColorGradient,
    ColorGradientPoint,
} from "../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeTile,
    BiomeFoliage,
    BiomeStructure,
    BiomeTerrainModifier,
    BiomeCreature,
    TileEntry,
} from "../lib/Biome";

// ============================================================================
// SHARED COLOR PALETTES
// ============================================================================

const SKY_TEMPERATE = new ColorGradient([
    new ColorGradientPoint(0.15, "#371479"),
    new ColorGradientPoint(0.45, "#5F91FE"),
    new ColorGradientPoint(0.72, "#C4502D"),
    new ColorGradientPoint(0.9, "#2b243f"),
]);

const SKY_ARID = new ColorGradient([
    new ColorGradientPoint(0.15, "#292231"),
    new ColorGradientPoint(0.45, "#D3BEA9"),
    new ColorGradientPoint(0.72, "#C66448"),
    new ColorGradientPoint(0.9, "#17121D"),
]);

const SKY_COLD = new ColorGradient([
    new ColorGradientPoint(0.15, "#371479"),
    new ColorGradientPoint(0.45, "#5F91FE"),
    new ColorGradientPoint(0.72, "#C4502D"),
    new ColorGradientPoint(0.9, "#2b243f"),
]);

const SKY_FROZEN = new ColorGradient([
    new ColorGradientPoint(0.15, "#394A6B"),
    new ColorGradientPoint(0.45, "#8BAED4"),
    new ColorGradientPoint(0.72, "#9A6A5F"),
    new ColorGradientPoint(0.9, "#1A1830"),
]);

const SKY_HUMID = new ColorGradient([
    new ColorGradientPoint(0.15, "#371479"),
    new ColorGradientPoint(0.45, "#5F91FE"),
    new ColorGradientPoint(0.72, "#C4502D"),
    new ColorGradientPoint(0.9, "#2b243f"),
]);

const STARLIGHT_SKY = new ColorGradient([
    new ColorGradientPoint(0.15, "#292231"),
    new ColorGradientPoint(0.45, "#5F91FE"),
    new ColorGradientPoint(0.72, "#C4502D"),
    new ColorGradientPoint(0.9, "#2b243f"),
]);

const LIGHT_DEFAULT = new ColorGradient([
    new ColorGradientPoint(0.15, "#374A91"),
    new ColorGradientPoint(0.45, "#FFFFFF"),
    new ColorGradientPoint(0.72, "#C68B69"),
    new ColorGradientPoint(0.9, "#141B35"),
]);

const LIGHT_ARID = new ColorGradient([
    new ColorGradientPoint(0.15, "#C68B69"),
    new ColorGradientPoint(0.45, "#FFFFFF"),
    new ColorGradientPoint(0.72, "#C68B69"),
    new ColorGradientPoint(0.9, "#141B35"),
]);

// ============================================================================
// SHARED TILE PALETTES
// ============================================================================

const TILES_GRASS = {
    top_layer: new BiomeTile("phantasia:grass_block", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:dirt", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
};

const TILES_SAND = {
    top_layer: new BiomeTile("phantasia:sand", [
        new TileEntry("phantasia:sandstone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:sand", [
        new TileEntry("phantasia:sandstone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:sandstone", [
        new TileEntry("phantasia:sandstone_wall", 3),
        new TileEntry("$EMPTY", 2),
    ]),
};

const TILES_TAIGA = {
    top_layer: new BiomeTile("phantasia:grass_block_taiga", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:dirt", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
};

const TILES_SWAMP = {
    top_layer: new BiomeTile("phantasia:grass_block_swamp", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    middle_layer: new BiomeTile("phantasia:dirt", [
        new TileEntry("phantasia:dirt_wall", 4),
        new TileEntry("$EMPTY", 1),
    ]),
    bottom_layer: new BiomeTile("phantasia:stone", [
        new TileEntry("phantasia:stone_wall", 4),
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

export default [
    // ========================================================================
    // EMERALDINE — Lush temperate biomes
    // ========================================================================

    // Greenia — Classic green forest
    new DatagenReturnData(
        "surface/emeraldine/greenia.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#32B559",
            SKY_TEMPERATE,
            LIGHT_DEFAULT,
            TILES_GRASS,
        )
            .setTerrainModifier(new BiomeTerrainModifier(0))
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.7),
                new Sound("phantasia:music/liminal", 0.7),
                new Sound("phantasia:music/red_apple", 0.6),
                new Sound("phantasia:music/soft_hour", 0.6),
                new Sound("phantasia:music/someday_it_will_rain", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.26).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rose", 0.07).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dandelion", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/oak", 0.1).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Birchwoods — White birch forest
    new DatagenReturnData(
        "surface/emeraldine/birchwoods.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#7ABF5E",
            SKY_TEMPERATE,
            LIGHT_DEFAULT,
            TILES_GRASS,
        )
            .setTerrainModifier(new BiomeTerrainModifier(0))
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.7),
                new Sound("phantasia:music/soft_hour", 0.6),
                new Sound("phantasia:music/someday_it_will_rain", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.22).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:globeflower", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/birch", 0.12).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Sakurai — Cherry blossom themed
    new DatagenReturnData(
        "surface/emeraldine/sakurai.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#E8A0C0",
            SKY_TEMPERATE,
            LIGHT_DEFAULT,
            TILES_GRASS,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-2))
            .setMusic([
                new Sound("phantasia:music/soft_hour", 0.6),
                new Sound("phantasia:music/someday_it_will_rain", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.2).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dendrobium", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/oak", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure(
                    "phantasia:tall_foliage/bamboo",
                    0.15,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ]),
    ),

    // Sunflora — Sunflower fields
    new DatagenReturnData(
        "surface/emeraldine/sunflora.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#E8D040",
            SKY_TEMPERATE,
            LIGHT_DEFAULT,
            TILES_GRASS,
        )
            .setTerrainModifier(new BiomeTerrainModifier(2))
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.7),
                new Sound("phantasia:music/red_apple", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.24).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dandelion", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure(
                    "phantasia:tall_foliage/sunflower",
                    0.08,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeStructure("phantasia:tree/oak", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Honeygrove — Sweet meadow
    new DatagenReturnData(
        "surface/emeraldine/honeygrove.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#C0A850",
            SKY_TEMPERATE,
            LIGHT_DEFAULT,
            TILES_GRASS,
        )
            .setTerrainModifier(new BiomeTerrainModifier(0))
            .setMusic([
                new Sound("phantasia:music/soft_hour", 0.6),
                new Sound("phantasia:music/red_apple", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.28).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:globeflower", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rose", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/oak", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // ========================================================================
    // ROTFENS — Humid swampy biomes
    // ========================================================================

    // Mangroots — Mangrove roots and murky water
    new DatagenReturnData(
        "surface/rotfens/mangroots.json",
        new Biome(
            new BiomeBackground("phantasia:background/swamp", 0.7),
            "#6B8C50",
            SKY_HUMID,
            LIGHT_DEFAULT,
            TILES_SWAMP,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-12, 0.7))
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.7),
                new Sound("phantasia:music/limerick", 0.7),
                new Sound("phantasia:music/ornaments_of_the_sky", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_swamp",
                    0.26,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_swamp",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure(
                    "phantasia:tall_foliage/cattail",
                    0.05,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeStructure(
                    [
                        "phantasia:tree/mangrove",
                        "phantasia:tree/mangrove_roots",
                    ],
                    0.1,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ]),
    ),

    // Boggins — Boggy wetlands
    new DatagenReturnData(
        "surface/rotfens/boggins.json",
        new Biome(
            new BiomeBackground("phantasia:background/swamp", 0.7),
            "#8C8C6C",
            SKY_HUMID,
            LIGHT_DEFAULT,
            TILES_SWAMP,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-15, 0.6))
            .setMusic([
                new Sound("phantasia:music/soliloquy", 0.6),
                new Sound("phantasia:music/sol_y_luna", 0.6),
                new Sound("phantasia:music/tense", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_swamp",
                    0.22,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_swamp",
                    0.05,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:lilybell", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:orchids", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:clump/moss", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // ========================================================================
    // DUSTBUNNY — Arid desert biomes
    // ========================================================================

    // Dune — Sandy desert
    new DatagenReturnData(
        "surface/dustbunny/dune.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#F4AF66",
            SKY_ARID,
            LIGHT_ARID,
            TILES_SAND,
        )
            .setTerrainModifier(new BiomeTerrainModifier(8, 0.8))
            .setMusic([
                new Sound("phantasia:music/dune", 0.3),
                new Sound("phantasia:music/oasis", 0.4),
                new Sound("phantasia:music/sol_y_luna", 0.5),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_dry",
                    0.14,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage("phantasia:dead_bush", 0.12).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure(
                    "phantasia:tall_foliage/cactus",
                    0.06,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ]),
    ),

    // Redwaste — Red desert
    new DatagenReturnData(
        "surface/dustbunny/redwaste.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#C45533",
            SKY_ARID,
            LIGHT_ARID,
            TILES_SAND,
        )
            .setTerrainModifier(new BiomeTerrainModifier(5, 0.9))
            .setMusic([
                new Sound("phantasia:music/dune", 0.3),
                new Sound("phantasia:music/tense", 0.5),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_dry",
                    0.1,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage("phantasia:dead_bush", 0.08).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // Badlands — Hilly rocky desert
    new DatagenReturnData(
        "surface/dustbunny/badlands.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#A65030",
            SKY_ARID,
            LIGHT_ARID,
            TILES_STONE,
        )
            .setTerrainModifier(new BiomeTerrainModifier(12, 1.4))
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.4),
                new Sound("phantasia:music/tense", 0.5),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.08).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
                new BiomeFoliage("phantasia:dead_bush", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // Oasin — Desert oasis
    new DatagenReturnData(
        "surface/dustbunny/oasin.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#60B878",
            SKY_ARID,
            LIGHT_ARID,
            TILES_SAND,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-4, 0.7))
            .setMusic([
                new Sound("phantasia:music/oasis", 0.4),
                new Sound("phantasia:music/soft_hour", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.18).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // Goldgrass — Golden steppe
    new DatagenReturnData(
        "surface/dustbunny/goldgrass.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#D4A840",
            SKY_ARID,
            LIGHT_ARID,
            TILES_SAND,
        )
            .setTerrainModifier(new BiomeTerrainModifier(4, 0.9))
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.4),
                new Sound("phantasia:music/sol_y_luna", 0.5),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_dry",
                    0.2,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_dry",
                    0.06,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage("phantasia:twig", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // ========================================================================
    // BOREA — Cold boreal biomes
    // ========================================================================

    // Pineling — Dense pine forest
    new DatagenReturnData(
        "surface/borea/pineling.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#097A67",
            SKY_COLD,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(4, 1.2))
            .setMusic([
                new Sound("phantasia:music/fall", 0.6),
                new Sound("phantasia:music/ornaments_of_the_sky", 0.5),
                new Sound("phantasia:music/winter_2012", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.26,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_taiga",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:bluebells", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/pine", 0.14).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Silversteep — High-altitude rocky taiga
    new DatagenReturnData(
        "surface/borea/silversteep.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#708888",
            SKY_COLD,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(8, 1.5))
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/soliloquy", 0.4),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.18,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:rock", 0.08).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/pine", 0.08).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Needlefall — Sparse coniferous forest
    new DatagenReturnData(
        "surface/borea/needlefall.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#3A7A55",
            SKY_COLD,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(0))
            .setMusic([
                new Sound("phantasia:music/fall", 0.6),
                new Sound("phantasia:music/tense", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.22,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_taiga",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:twig", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:daisy", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/pine", 0.1).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure("phantasia:clump/moss", 0.006).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ]),
    ),

    // Aurospring — Aurora meadow with flowers
    new DatagenReturnData(
        "surface/borea/aurospring.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#55A88C",
            SKY_COLD,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-2))
            .setMusic([
                new Sound("phantasia:music/ornaments_of_the_sky", 0.5),
                new Sound("phantasia:music/sol_y_luna", 0.5),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.24,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:bluebells", 0.08).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage(
                    "phantasia:seeding_dandelion",
                    0.03,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([])
            .setSkyScript("phantasia:sky/borea_aurora"),
    ),

    // ========================================================================
    // GLACIEN — Frozen tundra biomes
    // ========================================================================

    // Tundrune — Flat tundra
    new DatagenReturnData(
        "surface/glacien/tundrune.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#A0B8C0",
            SKY_FROZEN,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-4, 0.8))
            .setMusic([
                new Sound("phantasia:music/winter_2012", 0.7),
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.15,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:rock", 0.06).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // Flakerocks — Rocky frozen peaks
    new DatagenReturnData(
        "surface/glacien/flakerocks.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#808898",
            SKY_FROZEN,
            LIGHT_DEFAULT,
            TILES_STONE,
        )
            .setTerrainModifier(new BiomeTerrainModifier(6, 1.4))
            .setMusic([
                new Sound("phantasia:music/winter_2012", 0.7),
                new Sound("phantasia:music/tense", 0.6),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage("phantasia:rock", 0.1).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // Frostenisle — Flat frozen plain
    new DatagenReturnData(
        "surface/glacien/frostenisle.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#C8D8E0",
            SKY_FROZEN,
            LIGHT_DEFAULT,
            TILES_TAIGA,
        )
            .setTerrainModifier(new BiomeTerrainModifier(-6, 0.6))
            .setMusic([
                new Sound("phantasia:music/winter_2012", 0.7),
                new Sound("phantasia:music/soliloquy", 0.4),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.12,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:seeding_dandelion",
                    0.02,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:anemone", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setStructures([]),
    ),

    // ========================================================================
    // OCEAN — Shared between regions (kept as standalone)
    // ========================================================================
    new DatagenReturnData(
        "surface/ocean.json",
        new Biome(
            new BiomeBackground("phantasia:background/ocean", 0.7),
            "#2563A8",
            STARLIGHT_SKY,
            LIGHT_DEFAULT,
            {
                top_layer: new BiomeTile("phantasia:sand", [
                    new TileEntry("phantasia:sandstone_wall", 4),
                    new TileEntry("$EMPTY", 1),
                ]),
                middle_layer: new BiomeTile("phantasia:gravel", [
                    new TileEntry("phantasia:stone_wall", 4),
                    new TileEntry("$EMPTY", 1),
                ]),
                bottom_layer: new BiomeTile("phantasia:stone", [
                    new TileEntry("phantasia:stone_wall", 4),
                    new TileEntry("$EMPTY", 1),
                ]),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(-80, 0.3))
            .setIsOcean()
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/liminal", 0.7),
            ])
            .setCreatures([])
            .setFoliage([])
            .setStructures([]),
    ),
];
