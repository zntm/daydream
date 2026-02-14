import { ItemScript } from "../../items/lib";
import { EffectModifier } from "./EffectModifier";
import { EffectParticle } from "./EffectParticle";

export enum EffectType {
    Constant = "constant",
    OnDeath = "on_death",
    OnHit = "on_hit",
    Timed = "timed",
}

export class Effect {
    private type: EffectType;
    private attribute?: string;
    private base_value: number;
    private is_negative?: boolean;
    private modifiers?: EffectModifier[];
    private min_value?: number;
    private max_value?: number;
    private particle?: EffectParticle;
    private on_effect?: ItemScript;
    private on_death?: ItemScript;
    private icon?: string;

    constructor(type: EffectType, baseValue: number) {
        this.type = type;
        this.base_value = baseValue;
    }

    setIcon(icon: string): this {
        this.icon = icon;
        return this;
    }

    static constant(baseValue: number): Effect {
        return new Effect(EffectType.Constant, baseValue);
    }

    static onDeath(baseValue: number = 0): Effect {
        return new Effect(EffectType.OnDeath, baseValue);
    }

    static onHit(baseValue: number = 0): Effect {
        return new Effect(EffectType.OnHit, baseValue);
    }

    static timed(baseValue: number): Effect {
        return new Effect(EffectType.Timed, baseValue);
    }

    setAttribute(attribute: string): this {
        this.attribute = attribute;
        return this;
    }

    setIsNegative(isNegative: boolean): this {
        this.is_negative = isNegative;
        return this;
    }

    addModifier(modifier: EffectModifier): this {
        this.modifiers ??= [];
        this.modifiers.push(modifier);
        return this;
    }

    setMinValue(minValue: number): this {
        this.min_value = minValue;
        return this;
    }

    setMaxValue(maxValue: number): this {
        this.max_value = maxValue;
        return this;
    }

    setParticle(particle: EffectParticle): this {
        this.particle = particle;
        return this;
    }

    setOnEffect(script: ItemScript): this {
        this.on_effect = script;
        return this;
    }

    setOnDeath(script: ItemScript): this {
        this.on_death = script;
        return this;
    }
}
