import { DatagenReturnData } from "../../../lib";
import { Attribute } from "../../../lib/Attribute";
import { Effect, EffectModifier, EffectParticle } from "../lib";

export default ["bad_luck", "speed", "poison", "regeneration"].map((id) => {
    let effect: Effect;

    switch (id) {
        case "bad_luck":
            effect = Effect.constant(-1)
                .setIcon("phantasia:item/stone")
                .setAttribute("luck")
                .setIsNegative(true)
                .addModifier(EffectModifier.multiplyByLevel())
                .setParticle(
                    EffectParticle.sprite(
                        "phantasia:particle/entity/effect",
                        0.1,
                        "#5E5E5E",
                    ),
                );
            break;
        case "speed":
            effect = Effect.constant(0.2)
                .setIcon("phantasia:item/stone")
                .setAttribute("movement_speed")
                .addModifier(EffectModifier.multiplyByLevel())
                .setParticle(
                    EffectParticle.sprite(
                        "phantasia:particle/entity/effect",
                        0.2,
                        "#FFFFFF",
                    ),
                );
            break;
        case "poison":
            effect = Effect.constant(-1)
                .setIcon("phantasia:item/stone")
                .setAttribute("regeneration_amount")
                .setIsNegative(true)
                .addModifier(EffectModifier.multiplyByLevel())
                .setParticle(
                    EffectParticle.sprite(
                        "phantasia:particle/entity/effect",
                        0.2,
                        "#74C242",
                    ),
                );
            break;
        case "regeneration":
            effect = Effect.constant(1)
                .setIcon("phantasia:item/stone")
                .setAttribute("regeneration_amount")
                .addModifier(EffectModifier.multiplyByLevel())
                .setParticle(
                    EffectParticle.sprite(
                        "phantasia:particle/entity/effect",
                        0.1,
                        "#FF6666",
                    ),
                );
            break;
        default:
            throw new Error(`Unknown effect: ${id}`);
    }

    return new DatagenReturnData(`effects/${id}.json`, effect);
});
