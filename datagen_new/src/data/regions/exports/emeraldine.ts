import { Region, CaveBiomeRule } from "../lib";
import { ColorGradient } from "../../../lib/ColorGradient";
import { DatagenReturnData } from "../../../lib";

/**
 * Emeraldine - Forest Region
 * Biomes: greenia (regular forest), sunflora (sunflower fields),
 *         birchwoods (birch forest), cherrylis (cherry blossom)
 */
const emeraldine = new Region("emeraldine")
    .setBiomes([
        "phantasia:surface/greenia",
        "phantasia:surface/sunflora",
        "phantasia:surface/birchwoods",
        "phantasia:surface/cherrylis",
    ])
    .setBiomeNoiseScale(0.006)
    .setTerrain({
        height_offset: 0,
        base_height: 400,
        amplitude_min: 30,
        amplitude_max: 60,
        noise_scale: 0.015625,
        gradient_strength: 0.015,
    })
    .setSkyBaseColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#080812")
            .addPoint(0.2, "#1A1018")
            .addPoint(0.3, "#FF8E5C")
            .addPoint(0.5, "#6FBFFF")
            .addPoint(0.75, "#FF6B35")
            .addPoint(0.85, "#1A1018"),
    )
    .setSkyGradientColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#050508")
            .addPoint(0.2, "#0B0810")
            .addPoint(0.3, "#2C3CB4")
            .addPoint(0.5, "#1A66FF")
            .addPoint(0.75, "#8B2F97")
            .addPoint(0.85, "#0B0810"),
    )
    .setLightColorGradient(
        new ColorGradient()
            .addPoint(0.0, "#0A0A1F")
            .addPoint(0.3, "#FFD4A1")
            .addPoint(0.5, "#FFFFFF")
            .addPoint(0.75, "#FF9D6E")
            .addPoint(0.9, "#0A0A1F"),
    )
    .setCaveDefault("phantasia:cave/chasm")
    .addCaveBiome(
        new CaveBiomeRule("phantasia:cave/depths")
            .setDepthRange(150)
            .setNoiseThreshold(0.7, 0.015),
    )
    .setVoronoi(256, 0.4);

export default [
    new DatagenReturnData(`${emeraldine.getId()}.json`, emeraldine),
];
