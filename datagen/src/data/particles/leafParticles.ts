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
import { Particle, ParticleProperties } from "../particles";

export default ["birch", "oak", "pine"].map((id) => {
    return new DatagenReturnData(
        `generated/data/particles/tile/leaf/${id}.json`,
        new Particle(`phantasia:particle/tile/leaf/${id}`, [
            ParticleProperties.IsFadeOut,
        ])
            .setLifetime(
                new SmartValueFloatRandom(2, 4),
            )
            .setPhysics(
                new EntityPhysics(
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Reference,
                        "phantasia:weather_wind",
                        new SmartValueFloatRandom(-0.3, 0.3),
                        new SmartValueFloatRandom(0.5, 1.25),
                    ),
                    new SmartValueFloatRandom(0.6, 1.1),
                    new SmartValueFloatRandom(0.75, 1.25),
                    new EntityPhysicsValue(
                        EntityPhysicsValueType.Incremental,
                        new SmartValueFloatRandom(0.5, 1.25),
                    ).setIncrement(
                        new SmartValueFloatRandom(-16, 16),
                    ),
                ),
            )
            .setAttribute(new Attribute().setGravity(0.1)),
    );
});
