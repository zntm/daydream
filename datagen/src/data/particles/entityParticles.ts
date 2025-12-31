import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "../particles";

export default ["damage", "damage_critical"].map((id) => {
    return new DatagenReturnData(
        `generated/data/particles/entity/${id}.json`,
        new Particle(`phantasia:particle/entity/${id}`, [
            ParticleProperties.HasStretchAnimation,
        ])
            .setLifetime(new SmartValueFloatRandom(0.5, 1))
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(0.9, 1.1),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(0.8, 1.8),
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(200, 340),
            ))
            .setGravity(new ParticleGravity().setDirectional(0.1)),
    );
});
