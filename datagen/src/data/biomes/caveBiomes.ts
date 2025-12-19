import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Sound } from "../../lib/Sound";

import {
    Biome,
    BiomeBackground,
    BiomeCreature,
    BiomeFoliage,
    BiomeSkyColor,
    BiomeStructure,
    BiomeTile,
} from "../biomes";

export default [
    // Chasm
    new DatagenReturnData(
        "generated/data/biomes/cave/chasm.json",
        new Biome(
            new BiomeBackground("phantasia:background/chasm", 0.7),
            "#000000",
            {
                dawn: new BiomeSkyColor("#180738", "#2A1504"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#000019", "#020008"),
            },
            {
                dawn: "#374A91",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new BiomeTile(
                    "phantasia:stone",
                    "phantasia:stone_wall",
                ),
                middle_layer: new BiomeTile(
                    "phantasia:stone",
                    "phantasia:stone_wall",
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    "phantasia:stone_wall",
                ),
            },
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
    // Depths
    new DatagenReturnData(
        "generated/data/biomes/cave/depths.json",
        new Biome(
            new BiomeBackground("phantasia:background/depths", 0.7),
            "#000000",
            {
                dawn: new BiomeSkyColor("#180738", "#2A1504"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#000019", "#020008"),
            },
            {
                dawn: "#374A91",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new BiomeTile(
                    "phantasia:nightrock",
                    "phantasia:nightrock_wall",
                ),
                middle_layer: new BiomeTile(
                    "phantasia:nightrock",
                    "phantasia:nightrock_wall",
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:nightrock",
                    "phantasia:nightrock_wall",
                ),
            },
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
    // Lush Caves
    new DatagenReturnData(
        "generated/data/biomes/cave/lush_caves.json",
        new Biome(
            new BiomeBackground("phantasia:background/lush_caves", 0.7),
            "#32B559", // Forest color match for map reuse
            {
                dawn: new BiomeSkyColor("#180738", "#2A1504"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#000019", "#020008"),
            },
            {
                dawn: "#374A91",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new BiomeTile(
                    "phantasia:moss_block",
                    "phantasia:stone_wall",
                ),
                middle_layer: new BiomeTile(
                    "phantasia:stone",
                    "phantasia:stone_wall",
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    "phantasia:stone_wall",
                ),
            },
        )
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/soliloquy", 0.6),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:azalea", 0.1).setGenerateOn([
                    "phantasia:moss_block",
                ]),
                new BiomeFoliage("phantasia:flowering_azalea", 0.05).setGenerateOn([
                    "phantasia:moss_block",
                ]),
                new BiomeFoliage("phantasia:moss_carpet", 0.2).setGenerateOn([
                    "phantasia:moss_block",
                    "phantasia:stone"
                ]),
                new BiomeFoliage("phantasia:cave_vines", 0.15).setGenerateOn([
                    "phantasia:stone",
                ]),
            ])
            .setStructures([
                new BiomeStructure("phantasia:tree/azalea", 0.05).setGenerateOn(
                    "phantasia:moss_block",
                ),
                new BiomeStructure("phantasia:ore/coal", 0.005).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/copper", 0.005).setRange(
                    0,
                    768,
                ),
                new BiomeStructure("phantasia:ore/iron", 0.005).setRange(
                    640,
                    768,
                ),
            ]),
    ),
];
