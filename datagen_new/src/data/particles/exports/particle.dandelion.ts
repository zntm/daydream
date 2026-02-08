import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import {
    Particle,
    ParticleProperties,
    ParticleSize,
    ParticleSpeed,
    ParticleDirection,
} from "../lib";

const seedingDandelion = new Particle(
    "phantasia:particle/tile/seeding_dandelion",
    [ParticleProperties.HasCollision],
)
    .setLifetime(SmartValue.FloatRandom(0.75, 2.5))
    .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(1, 2)))
    .setSpeed(new ParticleSpeed(SmartValue.FloatRandom(0.75, 1.5)))
    .setDirection(new ParticleDirection(SmartValue.FloatRandom(240, 300)));

export default [
    new DatagenReturnData("tile/seeding_dandelion.json", seedingDandelion),
];
