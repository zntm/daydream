import { DatagenReturnData, SmartValue } from "../../lib";
import { Particle, ParticleProperties, ParticleSize } from "./lib/Particle";

export default [
    new DatagenReturnData(
        "explosion.json",
        new Particle(`phantasia:particle/explosion`, [
            ParticleProperties.HasStretchAnimation,
        ])
            .setLifetime(SmartValue.FloatRandom(0.5, 1))
            .setSize(
                new ParticleSize().setScale(SmartValue.FloatRandom(0.9, 1.1)),
            ),
    ),
];
