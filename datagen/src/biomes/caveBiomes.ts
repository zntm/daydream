import {
    DatagenReturnData,
    SmartValue,
    ChooseWeightedOption,
    SmartValueRandom,
    SmartValueType,
    Sound,
} from "../../index";
import {
    Biome,
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
            "phantasia:background/chasm",
            "#32B559",
            {
                dawn: new BiomeSkyColor("#180738", "#2A1504"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#000019", "#020008"),
            },
            {
                dawn: "#C4502D",
                day: "#5F91FE",
                dusk: "#C4502D",
                night: "#000019",
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
                new Sound("phantasia:12_hours_at_ease", 0.6),
                new Sound("phantasia:behind", 0.5),
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
            "phantasia:background/depths",
            "#32B559",
            {
                dawn: new BiomeSkyColor("#180738", "#2A1504"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
                dusk: new BiomeSkyColor("#C4502D", "#DA651C"),
                night: new BiomeSkyColor("#000019", "#020008"),
            },
            {
                dawn: "#C4502D",
                day: "#5F91FE",
                dusk: "#C4502D",
                night: "#000019",
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
                new Sound("phantasia:12_hours_at_ease", 0.7),
                new Sound("phantasia:behind", 0.6),
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
];
