import {
    DatagenReturnData,
    SmartValue,
    SmartValueRandom,
    SmartValueType,
} from "../../index";
import { Attribute } from "../attribute";
import { EntityPhysics, EntityPhysicsValue } from "../entity";
import { Particle, ParticleProperties } from "../particles";

export default [
    ...["entity/damage", "entity/damage_critical"].map((id) => {
        return new DatagenReturnData(
            `generated/data/particles/${id}.json`,
            new Particle(`phantasia:particle/${id}`, [
                ParticleProperties.HasStretchAnimation,
            ])
                .setLifetime(
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(0.5, 1),
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
                            new SmartValueRandom(-1.6, -0.4),
                        ),
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(0.9, 1.1),
                        ),
                    ),
                )
                .setAttribute(new Attribute().setGravity(0.1)),
        );
    }),
];
