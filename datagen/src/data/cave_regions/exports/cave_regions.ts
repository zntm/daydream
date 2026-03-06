import { DatagenReturnData } from "../../../lib";
import { CaveRegion, CaveRegionBiome } from "../lib/CaveRegion";

export default [
    new DatagenReturnData(
        "lumin.json",
        new CaveRegion("lumin", {
            biomes: [
                new CaveRegionBiome("phantasia:cave/moonfall", 1),
            ],
            noiseScale: 0.008,
            noiseThreshold: 0.66,
            minDepth: 20,
            salt: 31295,
        }),
    ),

    new DatagenReturnData(
        "mausoline.json",
        new CaveRegion("mausoline", {
            biomes: [
                new CaveRegionBiome("phantasia:cave/wiltens", 1),
            ],
            noiseScale: 0.008,
            noiseThreshold: 0.33,
            minDepth: 20,
            salt: 31295,
        }),
    ),

    new DatagenReturnData(
        "verdance.json",
        new CaveRegion("verdance", {
            biomes: [
                new CaveRegionBiome("phantasia:cave/wildroots", 1),
            ],
            noiseScale: 0.008,
            noiseThreshold: 0.0,
            minDepth: 20,
            salt: 31295,
        }),
    ),
];
