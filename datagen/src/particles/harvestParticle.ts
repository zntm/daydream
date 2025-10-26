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
        "generated/data/particles/tile/harvest.json",
        new Particle("phantasia:particle/harvest", [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValue(
                    SmartValueType.FloatRandom,
                    new SmartValueRandom(0.5, 1.25),
                ),
            )
            .setPhysics(
                new EntityPhysics(
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(-1, 1),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(-1.75, -0.5),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(1, 3),
                    ),
                ),
            )
            .setAttribute(new Attribute().setGravity(0.1)),
    ),
];
