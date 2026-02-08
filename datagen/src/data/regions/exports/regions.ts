import { DatagenReturnData } from "../../../lib";
import { Region, RegionCaveBiome, RegionTerrain } from "../lib/Region";

export default [
    new DatagenReturnData(
        "regions/regions.json",
        [
            new Region("forest", {
                category: "temperate",
                surfaceBiome: "phantasia:surface/forest",
                caveBiomeDefault: "phantasia:cave/chasm",
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 150, noiseThreshold: 0.7, noiseScale: 0.015 })
                ]
            }),
            new Region("desert", {
                category: "arid",
                surfaceBiome: "phantasia:surface/desert",
                caveBiomeDefault: "phantasia:cave/chasm",
                terrain: new RegionTerrain({
                    heightOffset: 10,
                    baseHeight: 410,
                    amplitudeMin: 15,
                    amplitudeMax: 35
                }),
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 250, noiseThreshold: 0.6 })
                ]
            }),
            new Region("taiga", {
                category: "cold",
                surfaceBiome: "phantasia:surface/taiga",
                caveBiomeDefault: "phantasia:cave/chasm",
                terrain: new RegionTerrain({
                    heightOffset: -20,
                    baseHeight: 380,
                    amplitudeMin: 20,
                    amplitudeMax: 50
                }),
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 100, noiseThreshold: 0.5 })
                ]
            })
        ]
    )
];
