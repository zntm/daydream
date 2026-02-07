import { DatagenReturnData } from "../../../lib";
import { SmartValue } from "../../../lib/SmartValue";
import {
    Particle,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "../lib";

const debris = new Particle("phantasia:particle/tile/harvest")
    .setLifetime(SmartValue.FloatRandom(0.5, 1.0))
    .setSize(new ParticleSize().setScale(SmartValue.FloatRandom(1, 3)))
    .setSpeed(new ParticleSpeed(SmartValue.FloatRandom(1, 2.5)))
    .setDirection(new ParticleDirection(SmartValue.FloatRandom(200, 340)))
    .setGravity(new ParticleGravity().setDirectional(0.2));

export default [
    new DatagenReturnData("debris.json", debris),
];
