import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import { Particle, ParticleProperties, ParticleSize } from "../lib";

const explosion = new Particle("phantasia:particle/explosion", [
    ParticleProperties.HasStretchAnimation,
])
    .setLifetime(SmartValue.FloatRandom(0.5, 1))
    .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(0.9, 1.1)));

export default [
    new DatagenReturnData("explosion.json", explosion),
];
