import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../lib";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "./lib/Particle";

export default [
    new DatagenReturnData(
        "generated/data/particles/tile/harvest.json",
        new Particle("phantasia:particle/tile/harvest")
            .setLifetime(new SmartValueFloatRandom(0.5, 1.25))
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(1, 3),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(0.8, 1.8),
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(20, 160),
            ))
            .setGravity(new ParticleGravity().setDirectional(3)),
    ),
];
