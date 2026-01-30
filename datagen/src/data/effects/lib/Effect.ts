import { ItemFunction } from "../../items/lib/ItemFunction";
import { EffectModifier } from "./EffectModifier";
import { EffectParticle } from "./EffectParticle";

export enum EffectType {
    Constant = "constant",
    OnDeath = "on_death",
    OnHit = "on_hit",
    Timed = "timed",
}

/**
 * Represents a status effect that can be applied to entities.
 * Unified with armor/accessory buff system for consistent modifier handling.
 */
export class Effect {
    private type: EffectType;
    private attribute?: string;
    private base_value: number;
    private is_negative?: boolean;
    private modifiers?: EffectModifier[];
    private min_value?: number;
    private max_value?: number;
    private particle?: EffectParticle;
    private on_effect?: ItemFunction;
    private on_death?: ItemFunction;
    private on_heal?: ItemFunction;
    private on_damage?: ItemFunction;
    private on_interval?: { tick: number; id: string; parameters?: Record<string, unknown> };
    private on_chance?: { chance: number; id: string; parameters?: Record<string, unknown> };
    private on_end?: ItemFunction;

    /**
     * @param type - Effect type (constant, on_death, on_hit, timed)
     * @param baseValue - Base value for calculations
     */
    private icon?: string;

    constructor(type: EffectType, baseValue: number) {
        this.type = type;
        this.base_value = baseValue;
    }

    setIcon(icon: string) {
        this.icon = icon;
        return this;
    }

    /**
     * Create a constant attribute modifier effect
     */
    static constant(baseValue: number) {
        return new Effect(EffectType.Constant, baseValue);
    }

    /**
     * Create an on-death trigger effect
     */
    static onDeath(baseValue: number = 0) {
        return new Effect(EffectType.OnDeath, baseValue);
    }

    /**
     * Create an on-hit trigger effect
     */
    static onHit(baseValue: number = 0) {
        return new Effect(EffectType.OnHit, baseValue);
    }

    /**
     * Create a timed effect
     */
    static timed(baseValue: number) {
        return new Effect(EffectType.Timed, baseValue);
    }

    setAttribute(attribute: string) {
        this.attribute = attribute;
        return this;
    }

    setIsNegative(isNegative: boolean) {
        this.is_negative = isNegative;
        return this;
    }

    addModifier(modifier: EffectModifier) {
        this.modifiers ??= [];
        this.modifiers.push(modifier);
        return this;
    }

    setMinValue(minValue: number) {
        this.min_value = minValue;
        return this;
    }

    setMaxValue(maxValue: number) {
        this.max_value = maxValue;
        return this;
    }

    setParticle(particle: EffectParticle) {
        this.particle = particle;
        return this;
    }

    setOnEffect(fn: ItemFunction) {
        this.on_effect = fn;
        return this;
    }

    setOnDeath(fn: ItemFunction) {
        this.on_death = fn;
        return this;
    }

    setOnHeal(fn: ItemFunction) {
        this.on_heal = fn;
        return this;
    }

    setOnDamage(fn: ItemFunction) {
        this.on_damage = fn;
        return this;
    }

    setOnInterval(tick: number, id: string, parameters?: Record<string, unknown>) {
        this.on_interval = { tick, id, parameters };
        return this;
    }

    setOnChance(chance: number, id: string, parameters?: Record<string, unknown>) {
        this.on_chance = { chance, id, parameters };
        return this;
    }

    setOnEnd(fn: ItemFunction) {
        this.on_end = fn;
        return this;
    }
}
