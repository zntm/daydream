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
import { Particle, ParticleProperties } from "../particles";

export default ["birch", "oak", "pine"].map((id) => {
    return new DatagenReturnData(
        `generated/data/particles/leaf/${id}.json`,
        new Particle(`phantasia:particle/leaf/${id}`, [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValue(
                    SmartValueType.FloatRandom,
                    new SmartValueRandom(2, 4),
                ),
            )
            .setPhysics(
                new EntityPhysics(
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Reference,
                        "phantasia:weather_wind",
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(-0.3, 0.3),
                        ),
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(0.5, 1.25),
                        ),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(0.6, 1.1),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(0.75, 1.25),
                    ),
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Incremental,
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(0.5, 1.25),
                        ),
                    ).setIncrement(
                        new SmartValue(
                            SmartValueType.FloatRandom,
                            new SmartValueRandom(-16, 16),
                        ),
                    ),
                ),
            )
            .setAttribute(new Attribute().setGravity(0.1)),
    );
});
