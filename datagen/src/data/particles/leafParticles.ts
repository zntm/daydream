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
    ParticleOrientation,
    ParticleProperties,
} from "./lib/Particle";

export default ["birch", "mangrove", "oak", "pine"].map((id) => {
    return new DatagenReturnData(
        `tile/leaf/${id}.json`,
        new Particle(`phantasia:particle/tile/leaf/${id}`, [
            ParticleProperties.HasCollision,
        ])
            .setLifetime(new SmartValueFloatRandom(4, 8))
            .setWindFactor(1.5)
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(0.75, 1.25),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(0.2, 0.5),
                undefined,
                undefined,
                new SmartValueFloatRandom(0.1, 0.3), // wiggle
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(250, 290),
                undefined,
                new SmartValueFloatRandom(-1, 1), // increment for drifting
            ))
            .setOrientation(new ParticleOrientation(
                new SmartValueFloatRandom(0.5, 1.25),
                undefined,
                new SmartValueFloatRandom(-16, 16), // increment
            ))
            .setGravity(new ParticleGravity().setDirectional(0.1)),
    );
});
