import {
    Biome,
    BiomeTile,
    BiomeTileLayer,
    BiomeTileEntry,
    BiomeMusic,
} from "../lib/Biome";

// Common tile configurations
const SANDSTONE_WALL = new BiomeTileEntry("phantasia:sandstone_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);

/**
 * Crest - Ocean biome (replaces ocean)
 */
const crest = new Biome("phantasia:surface/crest")
    .setBackground("phantasia:background/ocean", 0.7)
    .setIsOcean()
    .setTerrainModifier(-80, 0.3)
    .setTile(
        new BiomeTile(
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:sand")],
                [SANDSTONE_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:gravel")],
                [STONE_WALL, EMPTY_WALL],
            ),
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:stone")],
                [STONE_WALL, EMPTY_WALL],
            ),
        ),
    )
    .addMusic(new BiomeMusic("phantasia:music/12_hours_at_ease", 0.6))
    .addMusic(new BiomeMusic("phantasia:music/liminal", 0.7));

export default [crest.build()];
