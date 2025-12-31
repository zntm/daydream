import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "../particles";

export default [
    new DatagenReturnData(
        "generated/data/particles/debris.json",
        new Particle("phantasia:particle/tile/harvest")
            .setLifetime(new SmartValueFloatRandom(0.5, 1.0))
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(1, 3),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(1, 2.5),
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(200, 340),
            ))
            .setGravity(new ParticleGravity().setDirectional(0.2)),
    ),
];
