import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import { Attribute } from "../../attribute";
import { EntityPhysics, EntityPhysicsValue } from "../../entity";
import { Particle, ParticleProperties } from "../particles";

export default [
    ...["damage", "damage_critical"].map((id) => {
        return new DatagenReturnData(
            `generated/data/particles/entity/${id}.json`,
            new Particle(`phantasia:particle/entity/${id}`, [
                ParticleProperties.HasStretchAnimation,
            ])
                .setLifetime(
                    new SmartValueFloatRandom(0.5, 1),
                )
                .setPhysics(
                    new EntityPhysics(
                        new SmartValueFloatRandom(-1, 1),
                        new SmartValueFloatRandom(-1.6, -0.4),
                        new SmartValueFloatRandom(0.9, 1.1),
                    ),
                )
                .setAttribute(new Attribute().setGravity(0.1)),
        );
    }),
];
