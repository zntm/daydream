import { Region, CaveBiomeRule } from "../lib";
import { ColorGradient } from "../../../lib/ColorGradient";
import { DatagenReturnData } from "../../../lib";

/**
 * Dustbunny - Desert Region
 * Biomes: dune (regular desert)
 */
export const dustbunny = new Region("dustbunny")
    .setBiomes([
        "phantasia:surface/dune",
    ])
    .setBiomeNoiseScale(0.005)
    .setTerrain({
        height_offset: 0,
        base_height: 400,
        amplitude_min: 20,
        amplitude_max: 50,
        noise_scale: 0.015625,
        gradient_strength: 0.012,
    })
    .setSkyBaseColorGradient(new ColorGradient()
        .addPoint(0.00, "#0B0B1A")
        .addPoint(0.30, "#FFB085")
        .addPoint(0.50, "#FFE9D2")
        .addPoint(0.75, "#FF8E5C")
    )
    .setSkyGradientColorGradient(new ColorGradient()
        .addPoint(0.00, "#050508")
        .addPoint(0.30, "#4B66FF")
        .addPoint(0.50, "#7BBFFF")
        .addPoint(0.75, "#1E1F2B")
    )
    .setLightColorGradient(new ColorGradient()
        .addPoint(0.00, "#0F142A")
        .addPoint(0.30, "#FFD4A1")
        .addPoint(0.50, "#FFF4E5")
        .addPoint(0.75, "#FF9D6E")
    )
    .setCaveDefault("phantasia:cave/chasm")
    .addCaveBiome(
        new CaveBiomeRule("phantasia:cave/depths")
            .setDepthRange(250)
            .setNoiseThreshold(0.6)
    )
    .setVoronoi(256, 0.4);

export default [
    new DatagenReturnData(`${dustbunny.getId()}.json`, dustbunny),
];
