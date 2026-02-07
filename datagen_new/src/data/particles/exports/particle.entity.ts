import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "../lib";

export default ["damage", "damage_critical"].map((id) => {
    const particle = new Particle(`phantasia:particle/entity/${id}`, [
        ParticleProperties.HasStretchAnimation,
    ])
        .setLifetime(SmartValue.FloatRandom(0.5, 1))
        .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(0.9, 1.1)))
        .setSpeed(new ParticleSpeed(SmartValue.FloatRandom(0.8, 1.8)))
        .setDirection(new ParticleDirection(SmartValue.FloatRandom(200, 340)))
        .setGravity(new ParticleGravity().setDirectional(0.1));

    return new DatagenReturnData(`entity/${id}.json`, particle);
});
