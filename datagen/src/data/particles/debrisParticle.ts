import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import { Attribute } from "../../attribute";
import {
    EntityPhysics,
} from "../../entity";
import { Particle, ParticleProperties } from "../particles";

export default [
    new DatagenReturnData(
        "generated/data/particles/debris.json",
        new Particle("phantasia:particle/tile/harvest", [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValueFloatRandom(0.5, 1.0),
            )
            .setPhysics(
                new EntityPhysics(
                    new SmartValueFloatRandom(-2, 2),
                    new SmartValueFloatRandom(-2, -0.5),
                    new SmartValueFloatRandom(1, 3),
                ),
            )
            .setAttribute(new Attribute().setGravity(0.2)),
    ),
];
