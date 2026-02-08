import { SmartValue } from "../../../lib/SmartValue";
import {
    Biome,
    BiomeFoliage,
    BiomeTile,
    BiomeTileLayer,
    BiomeTileEntry,
    BiomeCreature,
    BiomeStructure,
    BiomeMusic,
} from "../lib/Biome";

// Common tile configurations
const DIRT_WALL = new BiomeTileEntry("phantasia:dirt_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);
const SAND_SHORE_BASE = new BiomeTileEntry("phantasia:sand");
const SANDSTONE_WALL = new BiomeTileEntry("phantasia:sandstone_wall", 4);

const DEFAULT_SHORE = new BiomeTileLayer(
    [SAND_SHORE_BASE],
    [SANDSTONE_WALL, EMPTY_WALL]
);

const FOREST_FOLIAGE = [
    new BiomeFoliage("phantasia:short_grass", 0.26),
    new BiomeFoliage("phantasia:tall_grass", 0.04),
    new BiomeFoliage("phantasia:rock", 0.04),
    new BiomeFoliage("phantasia:twig", 0.05),
    new BiomeFoliage("phantasia:globeflower", 0.05),
    new BiomeFoliage("phantasia:rose", 0.07),
    new BiomeFoliage("phantasia:dendrobium", 0.04),
    new BiomeFoliage("phantasia:dandelion", 0.03),
    new BiomeFoliage("phantasia:seeding_dandelion", 0.01),
];

const FOREST_MUSIC = [
    new BiomeMusic("phantasia:music/field_of_concourse", 0.7),
    new BiomeMusic("phantasia:music/liminal", 0.7),
    new BiomeMusic("phantasia:music/red_apple", 0.6),
    new BiomeMusic("phantasia:music/soft_hour", 0.6),
    new BiomeMusic("phantasia:music/someday_it_will_rain", 0.7),
];

/**
 * Greenia - Regular forest biome (replaces forest)
 */
const greenia = new Biome("phantasia:surface/greenia")
    .setBackground("phantasia:background/forest", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:grass_block")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:dirt")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:stone")],
            [STONE_WALL, EMPTY_WALL]
        )
    ))
    .setShoreTiles(DEFAULT_SHORE)
    .addCreature(
        new BiomeCreature("phantasia:chicken", SmartValue.IntRandom(1, 3), 0.03)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    )
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 4), 0.01)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    )
    .addCreature(
        new BiomeCreature("phantasia:fox", SmartValue.IntRandom(1, 3), 0.03)
    )
    .addStructure(new BiomeStructure("phantasia:clump/moss", 0.008))
    .addStructure(new BiomeStructure("phantasia:tree/oak", 0.1))
    .addStructure(new BiomeStructure("phantasia:tree/birch", 0.05));

// Add foliage
FOREST_FOLIAGE.forEach(f => greenia.addFoliage(f));
FOREST_MUSIC.forEach(m => greenia.addMusic(m));

/**
 * Sunflora - Sunflower fields biome
 */
const sunflora = new Biome("phantasia:surface/sunflora")
    .setBackground("phantasia:background/forest", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:grass_block")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:dirt")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:stone")],
            [STONE_WALL, EMPTY_WALL]
        )
    ))
    .setShoreTiles(DEFAULT_SHORE)
    .addFoliage(new BiomeFoliage("phantasia:short_grass", 0.2))
    .addFoliage(new BiomeFoliage("phantasia:tall_grass", 0.02))
    .addFoliage(new BiomeFoliage("phantasia:dandelion", 0.06))
    .addFoliage(new BiomeFoliage("phantasia:seeding_dandelion", 0.02))
    .addStructure(new BiomeStructure("phantasia:tall_foliage/sunflower", 0.15))
    .addStructure(new BiomeStructure("phantasia:tree/oak", 0.03))
    .addCreature(
        new BiomeCreature("phantasia:chicken", SmartValue.IntRandom(1, 4), 0.04)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    )
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 5), 0.02)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    );

FOREST_MUSIC.forEach(m => sunflora.addMusic(m));

/**
 * Birchwoods - Birch forest biome
 */
const birchwoods = new Biome("phantasia:surface/birchwoods")
    .setBackground("phantasia:background/forest", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:grass_block")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:dirt")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:stone")],
            [STONE_WALL, EMPTY_WALL]
        )
    ))
    .setShoreTiles(DEFAULT_SHORE)
    .addFoliage(new BiomeFoliage("phantasia:short_grass", 0.22))
    .addFoliage(new BiomeFoliage("phantasia:tall_grass", 0.03))
    .addFoliage(new BiomeFoliage("phantasia:rock", 0.03))
    .addFoliage(new BiomeFoliage("phantasia:twig", 0.06))
    .addFoliage(new BiomeFoliage("phantasia:dendrobium", 0.05))
    .addStructure(new BiomeStructure("phantasia:tree/birch", 0.14))
    .addStructure(new BiomeStructure("phantasia:tree/oak", 0.02))
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 3), 0.02)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    )
    .addCreature(
        new BiomeCreature("phantasia:fox", SmartValue.IntRandom(1, 2), 0.02)
    );

FOREST_MUSIC.forEach(m => birchwoods.addMusic(m));

/**
 * Cherrylis - Cherry blossom forest biome
 */
const cherrylis = new Biome("phantasia:surface/cherrylis")
    .setBackground("phantasia:background/forest", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:grass_block")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:dirt")],
            [DIRT_WALL, EMPTY_WALL]
        ),
        new BiomeTileLayer(
            [new BiomeTileEntry("phantasia:stone")],
            [STONE_WALL, EMPTY_WALL]
        )
    ))
    .setShoreTiles(DEFAULT_SHORE)
    .addFoliage(new BiomeFoliage("phantasia:short_grass", 0.18))
    .addFoliage(new BiomeFoliage("phantasia:tall_grass", 0.02))
    .addFoliage(new BiomeFoliage("phantasia:rose", 0.08))
    .addFoliage(new BiomeFoliage("phantasia:globeflower", 0.06))
    .addStructure(new BiomeStructure("phantasia:tree/cherry", 0.12))
    .addStructure(new BiomeStructure("phantasia:tree/oak", 0.02))
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 4), 0.015)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    );

FOREST_MUSIC.forEach(m => cherrylis.addMusic(m));

export default [
    greenia.build(),
    sunflora.build(),
    birchwoods.build(),
    cherrylis.build(),
];
