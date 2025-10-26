import { SmartValue } from "../index";

export class EntityPhysics {
    private xspeed: number | string | EntityPhysicsValue | SmartValue;
    private yspeed: number | string | EntityPhysicsValue | SmartValue;
    private scale?: number | string | EntityPhysicsValue | SmartValue;
    private rotation?: number | string | EntityPhysicsValue | SmartValue;

    constructor(
        xspeed: number | string | EntityPhysicsValue | SmartValue,
        yspeed: number | string | EntityPhysicsValue | SmartValue,
        scale: number | string | EntityPhysicsValue | SmartValue = 1,
        rotation: number | string | EntityPhysicsValue | SmartValue = 0,
    ) {
        this.xspeed = xspeed;
        this.yspeed = yspeed;
        this.scale = scale;
        this.rotation = rotation;
    }
}

export enum EntityPhysicsValueType {
    Exponential = "exponential",
    Incremental = "incremental",
    Reference = "reference",
}

export class EntityPhysicsValue {
    private type: EntityPhysicsValueType;
    private value: string | SmartValue;
    private offset?: string | SmartValue;
    private multiplier?: number | SmartValue;
    private increment?: number | string | SmartValue;
    private exponent?: number | string | SmartValue;

    constructor(
        type: EntityPhysicsValueType,
        value: string | SmartValue,
        offset?: string | SmartValue,
        multiplier?: number | SmartValue,
    ) {
        this.type = type;
        this.value = value;
        this.offset = offset;
        this.multiplier = multiplier;
    }

    setIncrement(increment: number | string | SmartValue) {
        this.increment = increment;

        return this;
    }

    setExponent(exponent: number | string | SmartValue) {
        this.exponent = exponent;

        return this;
    }
}
