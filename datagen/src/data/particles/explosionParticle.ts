/*
{
    "sprite": {
        "length": 10
    },
    "properties": [
        "phantasia:has_stretch_animation"
    ],
    "lifetime": {
        "type": "irandom",
        "values": {
            "min": 0.5,
            "max": 1
        }
    },
    "physics": {
        "scale": {
            "type": "random",
            "values": {
                "min": 0.9,
                "max": 1.1
            }
        }
    }
}*/

import {
    DatagenReturnData,
    SmartValueFloatRandom,
} from "../../..";
import { EntityPhysics } from "../../entity";
import { Particle, ParticleProperties } from "../particles";

export default [
    new DatagenReturnData(
        `generated/data/particles/explosion.json`,
        new Particle(`phantasia:particle/explosion`, [
            ParticleProperties.HasStretchAnimation,
        ])
            .setLifetime(
                new SmartValueFloatRandom(0.5, 1),
            )
            .setPhysics(
                new EntityPhysics(
                    0,
                    0,
                    new SmartValueFloatRandom(0.9, 1.1),
                ),
            ),
    ),
];
