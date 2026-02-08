import type { SmartValue } from "../../../lib";

export class ParticleSize {
    private xscale_min?: number | SmartValue;
    private xscale_max?: number | SmartValue;
    private xscale_increment?: number | SmartValue;
    private xscale_wiggle?: number | SmartValue;
    private yscale_min?: number | SmartValue;
    private yscale_max?: number | SmartValue;
    private yscale_increment?: number | SmartValue;
    private yscale_wiggle?: number | SmartValue;

    setXScale(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue) {
        this.xscale_min = min;
        this.xscale_max = max ?? min;
        this.xscale_increment = increment;
        this.xscale_wiggle = wiggle;

        return this;
    }

    setYScale(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue) {
        this.yscale_min = min;
        this.yscale_max = max ?? min;
        this.yscale_increment = increment;
        this.yscale_wiggle = wiggle;

        return this;
    }

    setScale(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue) {
        this.setXScale(min, max, increment, wiggle);
        this.setYScale(min, max, increment, wiggle);

        return this;
    }
}

export class ParticleOrientation {
    private angle_min?: number | SmartValue;
    private angle_max?: number | SmartValue;
    private angle_increment?: number | SmartValue;
    private angle_wiggle?: number | SmartValue;
    private angle_relative?: boolean;

    constructor(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue, relative?: boolean) {
        this.angle_min = min;
        this.angle_max = max ?? min;
        this.angle_increment = increment;
        this.angle_wiggle = wiggle;
        this.angle_relative = relative;

        return this;
    }
}

export class ParticleColor {
    private colour1?: string;
    private colour2?: string;
    private colour3?: string;
    private alpha1?: number | SmartValue;
    private alpha2?: number | SmartValue;
    private alpha3?: number | SmartValue;

    setColor(c1: string, c2?: string, c3?: string) {
        this.colour1 = c1;
        this.colour2 = c2;
        this.colour3 = c3;

        return this;
    }

    setAlpha(a1: number | SmartValue, a2?: number | SmartValue, a3?: number | SmartValue) {
        this.alpha1 = a1;
        this.alpha2 = a2;
        this.alpha3 = a3;

        return this;
    }
}

export class ParticleSpeed {
    private speed_min?: number | SmartValue;
    private speed_max?: number | SmartValue;
    private speed_increment?: number | SmartValue;
    private speed_wiggle?: number | SmartValue;

    constructor(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue) {
        this.speed_min = min;
        this.speed_max = max ?? min;
        this.speed_increment = increment;
        this.speed_wiggle = wiggle;
    }
}

export class ParticleDirection {
    private direction_min?: number | SmartValue;
    private direction_max?: number | SmartValue;
    private direction_increment?: number | SmartValue;
    private direction_wiggle?: number | SmartValue;

    constructor(min: number | SmartValue, max?: number | SmartValue, increment?: number | SmartValue, wiggle?: number | SmartValue) {
        this.direction_min = min;
        this.direction_max = max ?? min;
        this.direction_increment = increment;
        this.direction_wiggle = wiggle;
    }
}

export class ParticleGravity {
    private gravity_amount?: number | SmartValue;
    private gravity_direction?: number | SmartValue;
    private gravity_point_function?: string;
    private gravity_point_x?: number | SmartValue;
    private gravity_point_y?: number | SmartValue;

    setDirectional(amount: number | SmartValue, direction?: number | SmartValue) {
        this.gravity_amount = amount;
        this.gravity_direction = direction ?? 270;

        return this;
    }

    setPoint(x: number | SmartValue, y: number | SmartValue, force?: number | SmartValue) {
        this.gravity_point_x = x;
        this.gravity_point_y = y;

        if (force !== undefined) {
            this.gravity_amount = force;
        }

        return this;
    }

    setPointFunction(proglangSource: string, force?: number | SmartValue) {
        // todo: add using proglang
    }
}

export class ParticleFunction {
    private xspeed?: number | string | SmartValue;
    private yspeed?: number | string | SmartValue;
    private scale?: number | string | SmartValue;
    private rotation?: number | string | SmartValue;

    setOffset(
        x: number | string | SmartValue,
        y: number | string | SmartValue,
    ) {
        this.xspeed = x;
        this.yspeed = y;

        return this;
    }

    setScale(scale: number | string | SmartValue) {
        this.scale = scale;

        return this;
    }

    setRotation(rotation: number | string | SmartValue) {
        this.rotation = rotation;

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
    private lifetime?: number | string | SmartValue;
    private size?: ParticleSize;
    private orientation?: ParticleOrientation;
    private color?: ParticleColor;
    private speed?: ParticleSpeed;
    private direction?: ParticleDirection;
    private gravity?: ParticleGravity;

    constructor(
        sprite: string,
        properties?: ParticleProperties[],
    ) {
        this.sprite = sprite;
        this.properties = properties;
    }

    setLifetime(lifetime: number | string | SmartValue) {
        this.lifetime = lifetime;

        return this;
    }

    setSize(size: ParticleSize) {
        this.size = size;

        return this;
    }

    setOrientation(orientation: ParticleOrientation) {
        this.orientation = orientation;

        return this;
    }

    setColor(color: ParticleColor) {
        this.color = color;

        return this;
    }

    setSpeed(speed: ParticleSpeed) {
        this.speed = speed;

        return this;
    }

    setDirection(direction: ParticleDirection) {
        this.direction = direction;

        return this;
    }

    setGravity(gravity: ParticleGravity) {
        this.gravity = gravity;

        return this;
    }
}
