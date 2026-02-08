import { SmartValue, type SmartValueValueType } from "../../../lib/SmartValue";

export class ParticleSize {
    private xscale_min?: number | SmartValueValueType;
    private xscale_max?: number | SmartValueValueType;
    private xscale_increment?: number | SmartValueValueType;
    private xscale_wiggle?: number | SmartValueValueType;
    private yscale_min?: number | SmartValueValueType;
    private yscale_max?: number | SmartValueValueType;
    private yscale_increment?: number | SmartValueValueType;
    private yscale_wiggle?: number | SmartValueValueType;

    setXScale(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
    ): this {
        this.xscale_min = min;
        this.xscale_max = max ?? min;
        this.xscale_increment = increment;
        this.xscale_wiggle = wiggle;
        return this;
    }

    setYScale(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
    ): this {
        this.yscale_min = min;
        this.yscale_max = max ?? min;
        this.yscale_increment = increment;
        this.yscale_wiggle = wiggle;
        return this;
    }

    setScale(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
    ): this {
        this.setXScale(min, max, increment, wiggle);
        this.setYScale(min, max, increment, wiggle);
        return this;
    }
}

export class ParticleOrientation {
    private angle_min?: number | SmartValueValueType;
    private angle_max?: number | SmartValueValueType;
    private angle_increment?: number | SmartValueValueType;
    private angle_wiggle?: number | SmartValueValueType;
    private angle_relative?: boolean;

    constructor(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
        relative?: boolean,
    ) {
        this.angle_min = min;
        this.angle_max = max ?? min;
        this.angle_increment = increment;
        this.angle_wiggle = wiggle;
        this.angle_relative = relative;
    }
}

export class ParticleColor {
    private colour1?: string;
    private colour2?: string;
    private colour3?: string;
    private alpha1?: number | SmartValueValueType;
    private alpha2?: number | SmartValueValueType;
    private alpha3?: number | SmartValueValueType;

    setColor(c1: string, c2?: string, c3?: string): this {
        this.colour1 = c1;
        this.colour2 = c2;
        this.colour3 = c3;
        return this;
    }

    setAlpha(
        a1: number | SmartValueValueType,
        a2?: number | SmartValueValueType,
        a3?: number | SmartValueValueType,
    ): this {
        this.alpha1 = a1;
        this.alpha2 = a2;
        this.alpha3 = a3;
        return this;
    }
}

export class ParticleSpeed {
    private speed_min?: number | SmartValueValueType;
    private speed_max?: number | SmartValueValueType;
    private speed_increment?: number | SmartValueValueType;
    private speed_wiggle?: number | SmartValueValueType;

    constructor(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
    ) {
        this.speed_min = min;
        this.speed_max = max ?? min;
        this.speed_increment = increment;
        this.speed_wiggle = wiggle;
    }
}

export class ParticleDirection {
    private direction_min?: number | SmartValueValueType;
    private direction_max?: number | SmartValueValueType;
    private direction_increment?: number | SmartValueValueType;
    private direction_wiggle?: number | SmartValueValueType;

    constructor(
        min: number | SmartValueValueType,
        max?: number | SmartValueValueType,
        increment?: number | SmartValueValueType,
        wiggle?: number | SmartValueValueType,
    ) {
        this.direction_min = min;
        this.direction_max = max ?? min;
        this.direction_increment = increment;
        this.direction_wiggle = wiggle;
    }
}

export class ParticleGravity {
    private gravity_amount?: number | SmartValueValueType;
    private gravity_direction?: number | SmartValueValueType;
    private gravity_point_x?: number | SmartValueValueType;
    private gravity_point_y?: number | SmartValueValueType;

    setDirectional(
        amount: number | SmartValueValueType,
        direction?: number | SmartValueValueType,
    ): this {
        this.gravity_amount = amount;
        this.gravity_direction = direction ?? 270;
        return this;
    }

    setPoint(
        x: number | SmartValueValueType,
        y: number | SmartValueValueType,
        force?: number | SmartValueValueType,
    ): this {
        this.gravity_point_x = x;
        this.gravity_point_y = y;
        if (force !== undefined) {
            this.gravity_amount = force;
        }
        return this;
    }
}

export enum ParticleProperties {
    CanDestroyOnEntityCollision = "phantasia:can_destroy_on_entity_collision",
    CanDestroyOnTileCollision = "phantasia:can_destroy_on_tile_collision",
    HasStretchAnimation = "phantasia:has_stretch_animation",
    IsAdditive = "phantasia:is_additive",
    HasCollision = "phantasia:has_collision",
}

export class Particle {
    private sprite: string;
    private properties?: ParticleProperties[];
    private lifetime?: number | string | SmartValueValueType;
    private size?: ParticleSize;
    private orientation?: ParticleOrientation;
    private color?: ParticleColor;
    private speed?: ParticleSpeed;
    private direction?: ParticleDirection;
    private gravity?: ParticleGravity;

    constructor(sprite: string, properties?: ParticleProperties[]) {
        this.sprite = sprite;
        this.properties = properties;
    }

    setLifetime(lifetime: number | string | SmartValueValueType): this {
        this.lifetime = lifetime;
        return this;
    }

    setSize(size: ParticleSize): this {
        this.size = size;
        return this;
    }

    setOrientation(orientation: ParticleOrientation): this {
        this.orientation = orientation;
        return this;
    }

    setColor(color: ParticleColor): this {
        this.color = color;
        return this;
    }

    setSpeed(speed: ParticleSpeed): this {
        this.speed = speed;
        return this;
    }

    setDirection(direction: ParticleDirection): this {
        this.direction = direction;
        return this;
    }

    setGravity(gravity: ParticleGravity): this {
        this.gravity = gravity;
        return this;
    }
}
