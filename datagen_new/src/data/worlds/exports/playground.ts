import { World } from "../lib";
import { DatagenReturnData } from "../../../lib";

/**
 * Playground - Main test world
 */
const playground = new World("playground")
    .setWorldHeight(1024)
    .setSpawnInterval(14)
    .setRegionTransition({
        width: 32,
        noise_scale: 0.05,
        noise_amplitude: 8,
    })
    .setSurfaceBiomeMap("phantasia:world/playground/map");

export default [
    new DatagenReturnData(`${playground.getId()}.json`, playground),
];
