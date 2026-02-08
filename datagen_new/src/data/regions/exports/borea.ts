import { Region, CaveBiomeRule } from "../lib/Region";
import { ColorGradient } from "../../../lib/ColorGradient";
import { DatagenReturnData } from "../../../lib";

/**
 * Borea - Taiga/Cold Region
 * Biomes: pinesteep (regular taiga), silversteep (silver pine taiga)
 */
export const borea = new Region("borea")
    .setBiomes(["phantasia:surface/pinesteep", "phantasia:surface/silversteep"])
    .setTerrain({
        base_height: 480,
        amplitude_min: 40,
        amplitude_max: 120,
        gradient_strength: 0.02,
    })
    .setSkyBaseColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#050510")
            .addPoint(0.3, "#203050")
            .addPoint(0.5, "#6080A0")
            .addPoint(0.75, "#302040"),
    )
    .setSkyGradientColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#020205")
            .addPoint(0.3, "#405080")
            .addPoint(0.5, "#8090C0")
            .addPoint(0.75, "#201030"),
    )
    .setLightColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#050515")
            .addPoint(0.3, "#A0B0FF")
            .addPoint(0.5, "#E0E8FF")
            .addPoint(0.75, "#B0A0FF"),
    )
    .setCaveDefault("phantasia:cave/chasm")
    .addCaveBiome(
        new CaveBiomeRule("phantasia:cave/depths")
            .setDepthRange(100)
            .setNoiseThreshold(0.5),
    )
    .setVoronoi(256, 0.4);

export default [new DatagenReturnData(`${borea.getId()}.json`, borea)];
