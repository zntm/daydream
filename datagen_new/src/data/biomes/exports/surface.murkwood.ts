import {
    Biome,
    BiomeFoliage,
    BiomeTile,
    BiomeTileLayer,
    BiomeTileEntry,
    BiomeStructure,
    BiomeMusic,
} from "../lib/Biome";

// Common tile configurations
const DIRT_WALL = new BiomeTileEntry("phantasia:dirt_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);

/**
 * Murkwood - Swamp biome (replaces swamp)
 */
const murkwood = new Biome("phantasia:surface/murkwood")
    .setBackground("phantasia:background/swamp", 0.7)
    .setTerrainModifier(-12, 0.7)
    .setTile(
        new BiomeTile(
            new BiomeTileLayer(
                [new BiomeTileEntry("phantasia:grass_block_swamp")],
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
    .addFoliage(new BiomeFoliage("phantasia:short_grass_swamp", 0.26))
    .addFoliage(new BiomeFoliage("phantasia:tall_grass_swamp", 0.04))
    .addFoliage(new BiomeFoliage("phantasia:globeflower", 0.05))
    .addFoliage(new BiomeFoliage("phantasia:rock", 0.04))
    .addFoliage(new BiomeFoliage("phantasia:twig", 0.05))
    .addFoliage(new BiomeFoliage("phantasia:rose", 0.07))
    .addFoliage(new BiomeFoliage("phantasia:lilybell", 0.03))
    .addFoliage(new BiomeFoliage("phantasia:orchids", 0.03))
    .addFoliage(new BiomeFoliage("phantasia:dandelion", 0.04))
    .addFoliage(new BiomeFoliage("phantasia:seeding_dandelion", 0.01))
    .addStructure(new BiomeStructure("phantasia:clump/moss", 0.02))
    .addStructure(new BiomeStructure("phantasia:tall_foliage/cattail", 0.05))
    .addStructure(new BiomeStructure("phantasia:tree/mangrove", 0.1))
    .addMusic(new BiomeMusic("phantasia:music/12_hours_at_ease", 0.7))
    .addMusic(new BiomeMusic("phantasia:music/limerick", 0.7))
    .addMusic(new BiomeMusic("phantasia:music/ornaments_of_the_sky", 0.7))
    .addMusic(new BiomeMusic("phantasia:music/soliloquy", 0.6))
    .addMusic(new BiomeMusic("phantasia:music/sol_y_luna", 0.6))
    .addMusic(new BiomeMusic("phantasia:music/tense", 0.7));

export default [murkwood.build()];
