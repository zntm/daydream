import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../lib";
import {
    Particle,
    ParticleColor,
    ParticleSize,
    ParticleGravity,
    ParticleSpeed,
    ParticleDirection,
} from "./lib/Particle";

export default [
    new DatagenReturnData(
        "weather/raindrop.json",
        new Particle("phantasia:particle/weather/raindrop")
            .setLifetime(new SmartValueFloatRandom(0.4, 0.8))
            .setColor(new ParticleColor()
                .setAlpha(0, 1, 1),
            )
            .setSize(new ParticleSize().setScale(
                new SmartValueFloatRandom(0.8, 1.2),
            ))
            .setSpeed(new ParticleSpeed(
                new SmartValueFloatRandom(4, 6),
            ))
            .setDirection(new ParticleDirection(
                new SmartValueFloatRandom(250, 290),
            ))
            .setGravity(new ParticleGravity().setDirectional(0.3))
            .setWindFactor(1.0),
    ),
];
