import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
} from "../particles";

export default [
    new DatagenReturnData(
        `generated/data/particles/explosion.json`,
        new Particle(`phantasia:particle/explosion`, [
            ParticleProperties.HasStretchAnimation,
        ])
            .setLifetime(new SmartValueFloatRandom(0.5, 1))
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(0.9, 1.1),
            )),
    ),
];
