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
const SNOW_BASE = new BiomeTileEntry("phantasia:snow_block");

const TAIGA_MUSIC = [
    new BiomeMusic("phantasia:music/frozen_meadow", 0.6),
    new BiomeMusic("phantasia:music/winter_wind", 0.5),
];

/**
 * Pinesteep - Regular taiga biome (replaces taiga)
 */
const pinesteep = new Biome("phantasia:surface/pinesteep")
    .setBackground("phantasia:background/taiga", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [SNOW_BASE],
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
    .addFoliage(new BiomeFoliage("phantasia:snow_pile", 0.15))
    .addFoliage(new BiomeFoliage("phantasia:rock", 0.04))
    .addFoliage(new BiomeFoliage("phantasia:twig", 0.03))
    .addStructure(new BiomeStructure("phantasia:tree/pine", 0.12))
    .addStructure(new BiomeStructure("phantasia:tree/spruce", 0.06))
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 2), 0.01)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    );

TAIGA_MUSIC.forEach(m => pinesteep.addMusic(m));

/**
 * Silversteep - Taiga with silver pine variant (more silver pine leaves)
 */
const silversteep = new Biome("phantasia:surface/silversteep")
    .setBackground("phantasia:background/taiga", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer(
            [SNOW_BASE],
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
    .addFoliage(new BiomeFoliage("phantasia:snow_pile", 0.18))
    .addFoliage(new BiomeFoliage("phantasia:rock", 0.03))
    .addStructure(new BiomeStructure("phantasia:tree/silver_pine", 0.14))
    .addStructure(new BiomeStructure("phantasia:tree/pine", 0.04))
    .addCreature(
        new BiomeCreature("phantasia:rabbit", SmartValue.IntRandom(1, 2), 0.008)
            .setTimeRange(0, 890)
            .setTile("#phantasia:tile/creature_spawn/animal")
    );

TAIGA_MUSIC.forEach(m => silversteep.addMusic(m));

export default [
    pinesteep.build(),
    silversteep.build(),
];
