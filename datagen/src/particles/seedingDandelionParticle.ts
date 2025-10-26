import {
    DatagenReturnData,
    SmartValue,
    SmartValueRandom,
    SmartValueType,
} from "../../index";
import { Attribute } from "../attribute";
import {
    EntityPhysics,
    EntityPhysicsValue,
    EntityPhysicsValueType,
} from "../entity";
import { Particle, ParticleFunction, ParticleProperties } from "../particles";

export default [
    new DatagenReturnData(
        "generated/data/particles/tile/seeding_dandelion.json",
        new Particle("phantasia:particle/seeding_dandelion", [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValue(
                    SmartValueType.FloatRandom,
                    new SmartValueRandom(0.75, 2.5),
                ),
            )
            .setPhysics(
                new EntityPhysics(
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Reference,
                        "phantasia:weather_wind",
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(-0.1, 0.1),
                        ),
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(0.85, 1.5),
                        ),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(-1.1, -0.75),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(1, 2),
                    ),
                ),
            )
            .setAttribute(new Attribute().setCollisionBox(2, 2))
            .setOnCollision(new ParticleFunction().setOffset(0, 0)),
    ),
];
