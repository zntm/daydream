import { DatagenReturnData, SmartValue } from "../../lib";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "./lib/Particle";

export default [
    new DatagenReturnData(
        "tile/harvest.json",
        new Particle("phantasia:particle/tile/harvest")
            .setLifetime(SmartValue.FloatRandom(0.5, 1.25))
            .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(1, 3)))
            .setSpeed(new ParticleSpeed(SmartValue.FloatRandom(0.8, 1.8)))
            .setDirection(
                new ParticleDirection(SmartValue.FloatRandom(20, 160)),
            )
            .setGravity(new ParticleGravity().setDirectional(3)),
    ),
];
