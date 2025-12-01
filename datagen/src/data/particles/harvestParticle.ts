import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import { Attribute } from "../../attribute";
import {
    EntityPhysics,
    EntityPhysicsValue,
    EntityPhysicsValueType,
} from "../../entity";
import { Particle, ParticleFunction, ParticleProperties } from "../particles";

export default [
    new DatagenReturnData(
        "generated/data/particles/tile/harvest.json",
        new Particle("phantasia:particle/harvest", [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValueFloatRandom(0.5, 1.25),
            )
            .setPhysics(
                new EntityPhysics(
                    new SmartValueFloatRandom(-1, 1),
                    new SmartValueFloatRandom(-1.75, -0.5),
                    new SmartValueFloatRandom(1, 3),
                ),
            )
            .setAttribute(new Attribute().setGravity(0.1)),
    ),
];
