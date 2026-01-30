import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Sound } from "../../lib/Sound";

import {
    Biome,
    BiomeBackground,
    BiomeSkyColor,
    BiomeTerrainModifier,
    MaterialProvider,
    RuleDepth,
    RuleAirAbove,
} from "../biomes";

export default [
    // Floating Islands
    new DatagenReturnData(
        "generated/data/biomes/sky/floating_islands.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#87CEEB",
            {
                dawn: new BiomeSkyColor("#371479", "#4d1140"),
                day: new BiomeSkyColor("#87CEEB", "#5F91FE"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#2b243f", "#1e1f2b"),
            },
            {
                dawn: "#374A91",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new MaterialProvider()
                    .addItem("phantasia:grass_block", [new RuleAirAbove(1)])
                    .addItem("phantasia:dirt")
                    .addItemNoise("phantasia:dirt_wall", 0, 204)
                    .setDefault("phantasia:grass_block"),
                middle_layer: new MaterialProvider()
                    .addItem("phantasia:dirt")
                    .addItemNoise("phantasia:dirt_wall", 0, 204)
                    .setDefault("phantasia:dirt"),
                bottom_layer: new MaterialProvider()
                    .addItem("phantasia:stone")
                    .addItemNoise("phantasia:stone_wall", 0, 204)
                    .setDefault("phantasia:stone"),
            },
        )
            .setIsSkyland()
            .setTerrainModifier(new BiomeTerrainModifier(0, 0.015625, 40, 80, 5))
            .setMusic([
                new Sound("phantasia:music/ornaments_of_the_sky", 0.7),
                new Sound("phantasia:music/soft_hour", 0.6),
            ])
            .setCreatures([])
            .setFoliage([])
            .setStructures([]),
    ),
];
