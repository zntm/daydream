import { DatagenReturnData } from "../../../lib";
import { Effect } from "../lib/Effect";
import { EffectModifier } from "../lib/EffectModifier";
import { EffectParticle } from "../lib/EffectParticle";

/**
 * Effect definitions for the game.
 * Each effect is exported as a separate JSON file.
 */
const effects: { [key: string]: Effect } = {
    "bad_luck": Effect.constant(-1)
        .setIcon("phantasia:item/stone")
        .setAttribute("luck")
        .setIsNegative(true)
        .addModifier(EffectModifier.multiplyByLevel())
        .setParticle(EffectParticle.sprite("phantasia:particle/entity/effect", 0.1, "#5E5E5E")), // Grey

    "speed": Effect.constant(0.2)
        .setIcon("phantasia:item/stone")
        .setAttribute("movement_speed")
        .addModifier(EffectModifier.multiplyByLevel())
        .setParticle(EffectParticle.sprite("phantasia:particle/entity/effect", 0.2, "#FFFFFF")), // Cloud/White

    "poison": Effect.constant(-1)
        .setIcon("phantasia:item/stone")
        .setAttribute("regeneration_amount")
        .setIsNegative(true)
        .addModifier(EffectModifier.multiplyByLevel())
        .setParticle(EffectParticle.sprite("phantasia:particle/entity/effect", 0.2, "#74C242")), // Green

    "regeneration": Effect.constant(1)
        .setIcon("phantasia:item/stone")
        .setAttribute("regeneration_amount")
        .addModifier(EffectModifier.multiplyByLevel())
        .setParticle(EffectParticle.sprite("phantasia:particle/entity/effect", 0.1, "#FF6666")), // Heart/Red
};

// Generate individual JSON files for each effect
export default Object.entries(effects).map(
    ([id, data]): DatagenReturnData => new DatagenReturnData(`effects/${id}.json`, data)
);
