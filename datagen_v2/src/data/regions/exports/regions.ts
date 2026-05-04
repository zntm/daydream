import { DatagenReturnData } from "../../../lib";
import {
    Region,
    RegionBiome,
    RegionCaveBiome,
    RegionTerrain,
} from "../lib/Region";

export default [
    // Emeraldine - Lush temperate region
    new DatagenReturnData(
        "emeraldine.json",
        new Region("emeraldine", {
            category: "temperate",
            biomes: [
                new RegionBiome(
                    "phantasia:surface/emeraldine/greenia",
                    3,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/emeraldine/birchwoods",
                    2,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/emeraldine/sakurai",
                    1,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/emeraldine/sunflora",
                    2,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/emeraldine/honeygrove",
                    1,
                    "flat",
                ),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 150,
                    noiseThreshold: 0.7,
                    noiseScale: 0.015,
                }),
            ],
            terrain: new RegionTerrain({
                heightOffset: 0,
                amplitudeMin: 30,
                amplitudeMax: 60,
            }),
            mapColor: "#2D5A27",
        }),
    ),
    // Rotfens - Humid swampy region
    new DatagenReturnData(
        "rotfens.json",
        new Region("rotfens", {
            category: "humid",
            biomes: [
                new RegionBiome(
                    "phantasia:surface/rotfens/mangroots",
                    2,
                    "any",
                ),
                new RegionBiome("phantasia:surface/rotfens/boggins", 3, "flat"),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 200,
                    noiseThreshold: 0.6,
                }),
            ],
            terrain: new RegionTerrain({
                heightOffset: -12,
                amplitudeMin: 15,
                amplitudeMax: 30,
            }),
            mapColor: "#3D3D2D",
        }),
    ),

    // Dustbunny - Arid desert region
    new DatagenReturnData(
        "dustbunny.json",
        new Region("dustbunny", {
            category: "arid",
            biomes: [
                new RegionBiome("phantasia:surface/dustbunny/dune", 3, "flat"),
                new RegionBiome(
                    "phantasia:surface/dustbunny/redwaste",
                    2,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/dustbunny/badlands",
                    2,
                    "hilly",
                ),
                new RegionBiome("phantasia:surface/dustbunny/oasin", 1, "flat"),
                new RegionBiome(
                    "phantasia:surface/dustbunny/goldgrass",
                    2,
                    "any",
                ),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 250,
                    noiseThreshold: 0.6,
                }),
            ],
            terrain: new RegionTerrain({
                heightOffset: 8,
                amplitudeMin: 20,
                amplitudeMax: 50,
            }),
            mapColor: "#C2B280",
        }),
    ),

    // Borea - Cold boreal region
    new DatagenReturnData(
        "borea.json",
        new Region("borea", {
            category: "cold",
            biomes: [
                new RegionBiome("phantasia:surface/borea/pineling", 3, "any"),
                new RegionBiome(
                    "phantasia:surface/borea/silversteep",
                    2,
                    "hilly",
                ),
                new RegionBiome(
                    "phantasia:surface/borea/needlefall",
                    2,
                    "flat",
                ),
                new RegionBiome(
                    "phantasia:surface/borea/aurospring",
                    1,
                    "flat",
                ),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 100,
                    noiseThreshold: 0.5,
                }),
            ],
            terrain: new RegionTerrain({
                heightOffset: 4,
                amplitudeMin: 30,
                amplitudeMax: 65,
            }),
            mapColor: "#7BA1C7",
        }),
    ),

    new DatagenReturnData(
        "glacien.json",
        new Region("glacien", {
            category: "frozen",
            biomes: [
                new RegionBiome("phantasia:surface/glacien/tundrune", 3, "any"),
                new RegionBiome(
                    "phantasia:surface/glacien/flakerocks",
                    2,
                    "hilly",
                ),
                new RegionBiome(
                    "phantasia:surface/glacien/frostenisle",
                    2,
                    "flat",
                ),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 80,
                    noiseThreshold: 0.4,
                }),
            ],
            terrain: new RegionTerrain({
                heightOffset: -4,
                amplitudeMin: 20,
                amplitudeMax: 45,
            }),
            mapColor: "#E0FFFF",
        }),
    ),

    // Mausoline - Dark themed region
    new DatagenReturnData(
        "mausoline.json",
        new Region("mausoline", {
            category: "temperate",
            biomes: [
                // Surface biomes left minimal for now, or just some placeholder
                new RegionBiome("phantasia:surface/emeraldine/greenia", 3, "any"),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/wiltens", {
                    minDepth: 0,
                    // The request asked for generation size to be 1/3 lumin, 1/3 mausoline, 1/3 verdance.
                    // Assuming we generate them alongside each other. We use a somewhat large noiseScale
                    // so it forms large chunks. Z-layers and thresholds distinguish them.
                    noiseThreshold: 0.33,
                    noiseScale: 0.05,
                    weight: 10,
                }),
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 150,
                    noiseThreshold: 0.7,
                    noiseScale: 0.015,
                }),
            ],
            mapColor: "#3B2D46",
        }),
    ),

    // Verdance - Highly overgrown region
    new DatagenReturnData(
        "verdance.json",
        new Region("verdance", {
            category: "humid",
            biomes: [
                // Surface biomes left minimal for now
                new RegionBiome("phantasia:surface/rotfens/boggins", 3, "any"),
            ],
            caveBiomeDefault: "phantasia:cave/chasm",
            caveBiomes: [
                new RegionCaveBiome("phantasia:cave/wildroots", {
                    minDepth: 0,
                    noiseThreshold: 0.33,
                    noiseScale: 0.05,
                    weight: 10,
                }),
                new RegionCaveBiome("phantasia:cave/depths", {
                    minDepth: 150,
                    noiseThreshold: 0.7,
                    noiseScale: 0.015,
                }),
            ],
            mapColor: "#2F5128",
        }),
    ),
];
