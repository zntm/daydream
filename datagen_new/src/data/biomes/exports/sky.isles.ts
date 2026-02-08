import {
    Biome,
    BiomeTile,
    BiomeTileLayer,
    BiomeTileEntry,
    BiomeMusic,
} from "../lib/Biome";

// Common tile configurations
const DIRT_WALL = new BiomeTileEntry("phantasia:dirt_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);

/**
 * Aetheris - Floating Islands biome (replaces floating_islands)
 */
const aetheris = new Biome("phantasia:sky/aetheris")
    .setBackground("phantasia:background/forest", 0.7)
    .setIsSkyland()
    .setTerrainModifier(0, 0.5)
    .setTile(
        new BiomeTile(
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:grass_block")],
                [DIRT_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:dirt")],
                [DIRT_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:stone")],
                [STONE_WALL, EMPTY_WALL],
            ),
        ),
    )
    .addMusic(new BiomeMusic("phantasia:music/ornaments_of_the_sky", 0.7))
    .addMusic(new BiomeMusic("phantasia:music/soft_hour", 0.6));

export default [aetheris.build("sky")];
