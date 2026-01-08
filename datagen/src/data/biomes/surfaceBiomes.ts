import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { ChooseWeightedOption, SmartValueChooseWeighted, SmartValueIntRandom } from "../../lib/SmartValue";
import { Sound } from "../../lib/Sound";

import {
    Biome,
    BiomeBackground,
    BiomeCreature,
    BiomeFoliage,
    BiomeSkyColor,
    BiomeStructure,
    BiomeTerrainModifier,
    MaterialProvider,
    RuleDepth,
    RuleAirAbove,
} from "../biomes";

export default [
    // Desert
    new DatagenReturnData(
        "generated/data/biomes/surface/desert.json",
        new Biome(
            new BiomeBackground("phantasia:background/desert", 0.7),
            "#F4AF66",
            {
                dawn: new BiomeSkyColor("#292231", "#37232C"),
                day: new BiomeSkyColor("#D3BEA9", "#936E63"),
                dusk: new BiomeSkyColor("#C66448", "#AC6F56"),
                night: new BiomeSkyColor("#17121D", "#110A14"),
            },
            {
                dawn: "#C68B69",
                day: "#FFFFFF",
                dusk: "#C68B69",
                night: "#141B35",
            },
            {
                top_layer: new MaterialProvider()
                    .addItem("phantasia:sand")
                    .addItemNoise("phantasia:sandstone_wall", 0, 204) // Weighted logic: 4/5 = 80% = ~204/255
                    .setDefault("phantasia:sand"),
                middle_layer: new MaterialProvider()
                    .addItem("phantasia:sand")
                    .addItemNoise("phantasia:sandstone_wall", 0, 204)
                    .setDefault("phantasia:sand"),
                bottom_layer: new MaterialProvider()
                    .addItem("phantasia:sandstone")
                    .addItemNoise("phantasia:sandstone_wall", 0, 153) // Weighted logic: 3/5 = 60% = ~153/255
                    .setDefault("phantasia:sandstone"),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(8, 0.015625, 30, 60, 4))
            .setMusic([
                new Sound("phantasia:music/dune", 0.3),
                new Sound("phantasia:music/field_of_concourse", 0.4),
                new Sound("phantasia:music/oasis", 0.4),
                new Sound("phantasia:music/sol_y_luna", 0.5),
                new Sound("phantasia:music/tense", 0.5),
            ])
            .setCreatures([
                new BiomeCreature("phantasia:chicken", 1, 0.01)
                    .setTile("#phantasia:tile/creature_spawn/animal")
                    .setTimeRange(0, 890)
                    .setVariant("warm"),
            ])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_dry",
                    0.14,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_dry",
                    0.06,
                ).setGenerateOn("#phantasia:tile/placement/dry_plant_on"),
                new BiomeFoliage("phantasia:dead_bush", 0.12).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/dry_plant_on",
                ),
            ])
            .setStructures([
                new BiomeStructure(
                    "phantasia:tall_foliage/cactus",
                    0.06,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ])
            .setTags(["hot", "dry", "sand"]),
    ),
    // Forest
    new DatagenReturnData(
        "generated/data/biomes/surface/forest.json",
        new Biome(
            new BiomeBackground("phantasia:background/forest", 0.7),
            "#32B559",
            {
                dawn: new BiomeSkyColor("#371479", "#4d1140"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
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
                    .addItem("phantasia:dirt") // Fallback if no air above
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
            .setTerrainModifier(new BiomeTerrainModifier(0, 0.015625, 30, 60, 4))
            .setShoreTiles(new MaterialProvider()
                .addItem("phantasia:sand")
                .addItemNoise("phantasia:sandstone_wall", 0, 204)
                .setDefault("phantasia:sand")
            )
            .setMusic([
                new Sound("phantasia:music/field_of_concourse", 0.7),
                new Sound("phantasia:music/liminal", 0.7),
                new Sound("phantasia:music/red_apple", 0.6),
                new Sound("phantasia:music/soft_hour", 0.6),
                new Sound("phantasia:music/someday_it_will_rain", 0.7),
            ])
            .setCreatures([
                new BiomeCreature(
                    "phantasia:chicken",
                    new SmartValueIntRandom(1, 3),
                    0.03,
                )
                    .setTile("#phantasia:tile/creature_spawn/animal")
                    .setTimeRange(0, 890),
                new BiomeCreature(
                    "phantasia:rabbit",
                    new SmartValueIntRandom(1, 4),
                    0.01,
                )
                    .setTile("#phantasia:tile/creature_spawn/animal")
                    .setTimeRange(0, 890)
                    .setVariant(
                        new SmartValueChooseWeighted([
                            new ChooseWeightedOption("generic", 2),
                            new ChooseWeightedOption("white", 1),
                            new ChooseWeightedOption("spotted", 1),
                        ]),
                    ),
                new BiomeCreature(
                    "phantasia:fox",
                    new SmartValueIntRandom(1, 3),
                    0.03,
                ),
            ])
            .setFoliage([
                new BiomeFoliage("phantasia:short_grass", 0.26).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:tall_grass", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:globeflower", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rose", 0.07).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dendrobium", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dandelion", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage(
                    "phantasia:seeding_dandelion",
                    0.01,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ])
            .setStructures([
                new BiomeStructure("phantasia:clump/moss", 0.008).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure(
                    "phantasia:tall_foliage/sunflower",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeStructure("phantasia:tree/oak", 0.1).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure("phantasia:tree/birch", 0.07).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setTags(["forest", "temperate", "lush"]),
    ),
    // Swamp
    new DatagenReturnData(
        "generated/data/biomes/surface/swamp.json",
        new Biome(
            new BiomeBackground("phantasia:background/swamp", 0.7),
            "#8C8C6C",
            {
                dawn: new BiomeSkyColor("#371479", "#4d1140"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
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
                    .addItem("phantasia:grass_block_swamp", [new RuleAirAbove(1)])
                    .addItem("phantasia:dirt")
                    .addItemNoise("phantasia:dirt_wall", 0, 204)
                    .setDefault("phantasia:grass_block_swamp"),
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
            .setTerrainModifier(new BiomeTerrainModifier(-12, 0.015625, 20, 40, 4))
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.7),
                new Sound("phantasia:music/limerick", 0.7),
                new Sound("phantasia:music/ornaments_of_the_sky", 0.7),
                new Sound("phantasia:music/soliloquy", 0.6),
                new Sound("phantasia:music/sol_y_luna", 0.6),
                new Sound("phantasia:music/tense", 0.7),
            ])
            .setCreatures([])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_swamp",
                    0.26,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_swamp",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:globeflower", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:rose", 0.07).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:lilybell", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:orchids", 0.03).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:dandelion", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage(
                    "phantasia:seeding_dandelion",
                    0.01,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ])
            .setStructures([
                new BiomeStructure("phantasia:clump/moss", 0.02).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure(
                    "phantasia:tall_foliage/cattail",
                    0.05,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeStructure([
                    "phantasia:tree/mangrove",
                    "phantasia:tree/mangrove_roots",
                ], 0.1).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                )
            ])
            .setTags(["swamp", "wet", "lush"]),
    ),
    // Taiga
    new DatagenReturnData(
        "generated/data/biomes/surface/taiga.json",
        new Biome(
            new BiomeBackground("phantasia:background/taiga", 0.7),
            "#097A67",
            {
                dawn: new BiomeSkyColor("#371479", "#4d1140"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
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
                    .addItem("phantasia:grass_block_taiga", [new RuleAirAbove(1)])
                    .addItem("phantasia:dirt")
                    .addItemNoise("phantasia:dirt_wall", 0, 204)
                    .setDefault("phantasia:grass_block_taiga"),
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
            .setTerrainModifier(new BiomeTerrainModifier(4, 0.015625, 40, 80, 5))
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/fall", 0.6),
                new Sound("phantasia:music/ornaments_of_the_sky", 0.5),
                new Sound("phantasia:music/sol_y_luna", 0.5),
                new Sound("phantasia:music/soliloquy", 0.4),
                new Sound("phantasia:music/tense", 0.6),
                new Sound("phantasia:music/winter_2012", 0.7),
            ])
            .setCreatures([
                new BiomeCreature(
                    "phantasia:rabbit",
                    new SmartValueIntRandom(1, 4),
                    0.01,
                )
                    .setTile("#phantasia:tile/creature_spawn/animal")
                    .setTimeRange(0, 890)
                    .setVariant(
                        new SmartValueChooseWeighted([
                            new ChooseWeightedOption("black", 1),
                            new ChooseWeightedOption("spotted", 2),
                        ]),
                    ),
                new BiomeCreature(
                    "phantasia:fox",
                    new SmartValueIntRandom(1, 3),
                    0.03,
                ).setVariant("cold"),
            ])
            .setFoliage([
                new BiomeFoliage(
                    "phantasia:short_grass_taiga",
                    0.26,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage(
                    "phantasia:tall_grass_taiga",
                    0.04,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
                new BiomeFoliage("phantasia:rock", 0.04).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:twig", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:bluebells", 0.05).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage("phantasia:daisy", 0.07).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeFoliage(
                    "phantasia:seeding_dandelion",
                    0.02,
                ).setGenerateOn("#phantasia:tile/placement/plant_on"),
            ])
            .setStructures([
                new BiomeStructure("phantasia:clump/moss", 0.006).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
                new BiomeStructure("phantasia:tree/pine", 0.14).setGenerateOn(
                    "#phantasia:tile/placement/plant_on",
                ),
            ])
            .setTags(["forest", "cold", "snow"]),
    ),
    // Ocean
    new DatagenReturnData(
        "generated/data/biomes/surface/ocean.json",
        new Biome(
            new BiomeBackground("phantasia:background/ocean", 0.7),
            "#2563A8",
            {
                dawn: new BiomeSkyColor("#292231", "#37232C"),
                day: new BiomeSkyColor("#5F91FE", "#244FE9"),
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
                    .addItem("phantasia:sand")
                    .addItemNoise("phantasia:sandstone_wall", 0, 204)
                    .setDefault("phantasia:sand"),
                middle_layer: new MaterialProvider()
                    .addItem("phantasia:gravel")
                    .addItemNoise("phantasia:stone_wall", 0, 204)
                    .setDefault("phantasia:gravel"),
                bottom_layer: new MaterialProvider()
                    .addItem("phantasia:stone")
                    .addItemNoise("phantasia:stone_wall", 0, 204)
                    .setDefault("phantasia:stone"),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(-80, 0.015625, 10, 20, 3))
            .setIsOcean()
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/liminal", 0.7),
            ])
            .setCreatures([])
            .setFoliage([])
            .setStructures([])
            .setTags(["ocean", "water", "wet"]),
    ),
];
