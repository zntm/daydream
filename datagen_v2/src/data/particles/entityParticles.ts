import { DatagenReturnData, SmartValue } from "../../lib";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "./lib/Particle";

export default ["damage", "damage_critical"].map((id) => {
    return new DatagenReturnData(
        `entity/${id}.json`,

        new Particle(`phantasia:particle/entity/${id}`, [
            ParticleProperties.HasStretchAnimation,
        ])
            .setLifetime(SmartValue.FloatRandom(0.5, 1))
            .setSize(
                new ParticleSize().setScale(SmartValue.FloatRandom(0.9, 1.1)),
            )
            .setSpeed(new ParticleSpeed(SmartValue.FloatRandom(0.8, 1.8)))
            .setDirection(
                new ParticleDirection(SmartValue.FloatRandom(200, 340)),
            )
            .setGravity(new ParticleGravity().setDirectional(0.1)),
    );
});
