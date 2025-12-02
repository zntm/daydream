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
        "generated/data/particles/tile/seeding_dandelion.json",
        new Particle("phantasia:particle/tile/seeding_dandelion", [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValueFloatRandom(0.75, 2.5),
            )
            .setPhysics(
                new EntityPhysics(
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Reference,
                        "phantasia:weather_wind",
                        new SmartValueFloatRandom(-0.1, 0.1),
                        new SmartValueFloatRandom(0.85, 1.5),
                    ),
                    new SmartValueFloatRandom(-1.1, -0.75),
                    new SmartValueFloatRandom(1, 2),
                ),
            )
            .setAttribute(new Attribute().setCollisionBox(2, 2))
            .setOnCollision(new ParticleFunction().setOffset(0, 0)),
    ),
];
