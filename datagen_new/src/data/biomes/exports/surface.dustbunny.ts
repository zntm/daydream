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
const SANDSTONE_WALL = new BiomeTileEntry("phantasia:sandstone_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);

/**
 * Dune - Regular desert biome (replaces desert)
 */
const dune = new Biome("phantasia:surface/dune")
    .setBackground("phantasia:background/desert", 0.7)
    .setTerrainModifier(0, 0.8) // Flatter terrain
    .setTile(
        new BiomeTile(
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:sand")],
                [SANDSTONE_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:sandstone")],
                [SANDSTONE_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:stone")],
                [STONE_WALL, EMPTY_WALL],
            ),
        ),
    )
    .addFoliage(new BiomeFoliage("phantasia:dead_bush", 0.02))
    .addFoliage(new BiomeFoliage("phantasia:rock", 0.03))
    .addStructure(new BiomeStructure("phantasia:cactus/small", 0.05))
    .addStructure(new BiomeStructure("phantasia:cactus/large", 0.02))
    .addMusic(new BiomeMusic("phantasia:music/desert_wind", 0.6));

export default [dune.build()];
