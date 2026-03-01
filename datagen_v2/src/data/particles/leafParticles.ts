import { DatagenReturnData, SmartValue } from "../../lib";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
    ParticleOrientation,
    ParticleProperties,
} from "./lib/Particle";

export default ["birch", "mangrove", "oak", "pine"].map((id) => {
    return new DatagenReturnData(
        `tile/leaf/${id}.json`,
        new Particle(`phantasia:particle/tile/leaf/${id}`, [
            ParticleProperties.HasCollision,
        ])
            .setLifetime(SmartValue.FloatRandom(4, 8))
            .setWindFactor(1.5)
            .setSize(
                new ParticleSize().setScale(SmartValue.FloatRandom(0.75, 1.25)),
            )
            .setSpeed(
                new ParticleSpeed(
                    SmartValue.FloatRandom(0.2, 0.5),
                    undefined,
                    undefined,
                    SmartValue.FloatRandom(0.1, 0.3), // wiggle
                ),
            )
            .setDirection(
                new ParticleDirection(
                    SmartValue.FloatRandom(250, 290),
                    undefined,
                    SmartValue.FloatRandom(-1, 1), // increment for drifting
                ),
            )
            .setOrientation(
                new ParticleOrientation(
                    SmartValue.FloatRandom(0.5, 1.25),
                    undefined,
                    SmartValue.FloatRandom(-16, 16), // increment
                ),
            )
            .setGravity(new ParticleGravity().setDirectional(0.1)),
    );
});
