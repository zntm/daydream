import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
    ParticleSpeed,
    ParticleDirection,
} from "../particles";

export default [
    new DatagenReturnData(
        "generated/data/particles/tile/seeding_dandelion.json",
        new Particle("phantasia:particle/tile/seeding_dandelion", [
            ParticleProperties.HasCollision,
        ])
            .setLifetime(new SmartValueFloatRandom(0.75, 2.5))
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(1, 2),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(0.75, 1.5),
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(240, 300),
            )),
    ),
];
