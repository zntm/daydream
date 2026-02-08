import { DatagenReturnData } from "../../../../lib";
import { SmartValueChooseWeighted, SmartValueIntRandom, SmartValueChooseWeightedOption } from "../../../../lib";
import { Sound } from "../../../../lib";

import {
    Biome,
    BiomeBackground,
    BiomeCreature,
    BiomeFoliage,
    BiomeSkyColor,
    BiomeStructure,
    BiomeTile,
    BiomeTerrainModifier,
    TileEntry,
} from "../../lib/Biome";

export default [
    // Desert
    new DatagenReturnData(
        "surface/desert.json",
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
                top_layer: new BiomeTile(
                    "phantasia:sand",
                    [
                        new TileEntry("phantasia:sandstone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:sand",
                    [
                        new TileEntry("phantasia:sandstone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:sandstone",
                    [
                        new TileEntry("phantasia:sandstone_wall", 3),
                        new TileEntry("$EMPTY", 2),
                    ],
                ),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(8, 0.8))
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
            ]),
    ),
    // Forest
    new DatagenReturnData(
        "surface/forest.json",
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
                top_layer: new BiomeTile(
                    "phantasia:grass_block",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:dirt",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(0))
            .setShoreTiles(new BiomeTile(
                "phantasia:sand",
                [
                    new TileEntry("phantasia:sandstone_wall", 4),
                    new TileEntry("$EMPTY", 1),
                ],
            ))
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
                            new SmartValueChooseWeightedOption("generic", 2),
                            new SmartValueChooseWeightedOption("white", 1),
                            new SmartValueChooseWeightedOption("spotted", 1),
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
            ]),
    ),
    // Swamp
    new DatagenReturnData(
        "surface/swamp.json",
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
                top_layer: new BiomeTile(
                    "phantasia:grass_block_swamp",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:dirt",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(-12, 0.7))
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
            ]),
    ),
    // Taiga
    new DatagenReturnData(
        "surface/taiga.json",
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
                top_layer: new BiomeTile(
                    "phantasia:grass_block_taiga",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:dirt",
                    [
                        new TileEntry("phantasia:dirt_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(4, 1.2))
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
                            new SmartValueChooseWeightedOption("black", 1),
                            new SmartValueChooseWeightedOption("spotted", 2),
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
            ]),
    ),
    // Ocean
    new DatagenReturnData(
        "surface/ocean.json",
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
                top_layer: new BiomeTile(
                    "phantasia:sand",
                    [
                        new TileEntry("phantasia:sandstone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                middle_layer: new BiomeTile(
                    "phantasia:gravel",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
                bottom_layer: new BiomeTile(
                    "phantasia:stone",
                    [
                        new TileEntry("phantasia:stone_wall", 4),
                        new TileEntry("$EMPTY", 1),
                    ],
                ),
            },
        )
            .setTerrainModifier(new BiomeTerrainModifier(-80, 0.3))
            .setIsOcean()
            .setMusic([
                new Sound("phantasia:music/12_hours_at_ease", 0.6),
                new Sound("phantasia:music/liminal", 0.7),
            ])
            .setCreatures([])
            .setFoliage([])
            .setStructures([]),
    ),
];
