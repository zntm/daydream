import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
    ParticleOrientation,
} from "../lib";

export default ["birch", "oak", "pine"].map((id) => {
    const particle = new Particle(`phantasia:particle/tile/leaf/${id}`)
        .setLifetime(SmartValue.FloatRandom(2, 4))
        .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(0.75, 1.25)))
        .setSpeed(
            new ParticleSpeed(
                SmartValue.FloatRandom(0.6, 1.1),
                undefined,
                undefined,
                SmartValue.FloatRandom(0.1, 0.3)
            )
        )
        .setDirection(
            new ParticleDirection(
                SmartValue.FloatRandom(250, 290),
                undefined,
                SmartValue.FloatRandom(-1, 1)
            )
        )
        .setOrientation(
            new ParticleOrientation(
                SmartValue.FloatRandom(0.5, 1.25),
                undefined,
                SmartValue.FloatRandom(-16, 16)
            )
        )
        .setGravity(new ParticleGravity().setDirectional(0.1));

    return new DatagenReturnData(`tile/leaf/${id}.json`, particle);
});
