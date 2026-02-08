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
const STONE_WALL = new BiomeTileEntry("phantasia:stone_wall", 4);
const NIGHTROCK_WALL = new BiomeTileEntry("phantasia:nightrock_wall", 4);
const EMPTY_WALL = new BiomeTileEntry("$EMPTY");

// Common cave decorations
const CAVE_FOLIAGE = [
    new BiomeFoliage("phantasia:rock", 0.07, "phantasia:stone"),
    new BiomeFoliage("phantasia:twig", 0.0007, "phantasia:stone"),
];

const CAVE_ORES = [
    new BiomeStructure("phantasia:ore/coal", 0.003).setRange(0, 768),
    new BiomeStructure("phantasia:ore/copper", 0.003).setRange(0, 768),
    new BiomeStructure("phantasia:ore/iron", 0.003).setRange(640, 768),
    new BiomeStructure("phantasia:ore/iron", 0.003).setRange(712, 768),
];

const CAVE_MUSIC = [
    new BiomeMusic("phantasia:music/12_hours_at_ease", 0.6),
    new BiomeMusic("phantasia:music/behind", 0.5),
];

/**
 * Chasm - Upper cave biome
 */
const chasm = new Biome("phantasia:cave/chasm")
    .setBackground("phantasia:background/chasm", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer([new BiomeTileEntry("phantasia:stone")], [STONE_WALL, EMPTY_WALL]),
        new BiomeTileLayer([new BiomeTileEntry("phantasia:stone")], [STONE_WALL, EMPTY_WALL]),
        new BiomeTileLayer([new BiomeTileEntry("phantasia:stone")], [STONE_WALL, EMPTY_WALL])
    ));

/**
 * Depths - Lower cave biome
 */
const depths = new Biome("phantasia:cave/depths")
    .setBackground("phantasia:background/depths", 0.7)
    .setTile(new BiomeTile(
        new BiomeTileLayer([new BiomeTileEntry("phantasia:nightrock")], [NIGHTROCK_WALL, EMPTY_WALL]),
        new BiomeTileLayer([new BiomeTileEntry("phantasia:nightrock")], [NIGHTROCK_WALL, EMPTY_WALL]),
        new BiomeTileLayer([new BiomeTileEntry("phantasia:nightrock")], [NIGHTROCK_WALL, EMPTY_WALL])
    ));

// Shared decorations
[chasm, depths].forEach(b => {
    CAVE_FOLIAGE.forEach(f => b.addFoliage(f));
    CAVE_ORES.forEach(o => b.addStructure(o));
    CAVE_MUSIC.forEach(m => b.addMusic(m));
});

export default [
    chasm.build("cave"),
    depths.build("cave"),
];
