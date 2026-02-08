import { DatagenReturnData } from "../../../lib";
import { CaveBiomeRule, Region } from "../lib/Region";

const regions = [
    new Region("forest")
        .setCategory("temperate")
        .setBiomes(["phantasia:surface/forest"])
        .setCaveDefault("phantasia:cave/chasm")
        .addCaveBiome(
            new CaveBiomeRule("phantasia:cave/depths")
                .setDepthRange(150, 1024)
                .setNoiseThreshold(0.7, 0.015)
        ),

    new Region("desert")
        .setCategory("arid")
        .setBiomes(["phantasia:surface/desert"])
        .setCaveDefault("phantasia:cave/chasm")
        .setTerrain({
            height_offset: 10,
            base_height: 410,
            amplitude_min: 15,
            amplitude_max: 35,
        })
        .addCaveBiome(
            new CaveBiomeRule("phantasia:cave/depths")
                .setDepthRange(250, 1024)
                .setNoiseThreshold(0.6)
        ),

    new Region("taiga")
        .setCategory("cold")
        .setBiomes(["phantasia:surface/taiga"])
        .setCaveDefault("phantasia:cave/chasm")
        .setTerrain({
            height_offset: -20,
            base_height: 380,
            amplitude_min: 20,
            amplitude_max: 50,
        })
        .addCaveBiome(
            new CaveBiomeRule("phantasia:cave/depths")
                .setDepthRange(100, 1024)
                .setNoiseThreshold(0.5)
        ),
];

export default regions.map(
    (region) =>
        new DatagenReturnData(`${region.getId()}.json`, region)
);
