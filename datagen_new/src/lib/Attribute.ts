export enum AttributeBoolean {
    IsFallDamageResistant = "phantasia:is_fall_damage_resistant",
}

export class Attribute {
    collision_box_width?: number;
    collision_box_height?: number;
    hit_box_width?: number;
    hit_box_height?: number;
    eye_level?: number;
    gravity?: number;
    jump_falloff?: number;
    jump_height?: number;
    jump_time?: number;
    jump_count_max?: number;
    movement_speed?: number;
    boolean?: AttributeBoolean[];

    setCollisionBox(width: number, height: number): this {
        this.collision_box_width = width;
        this.collision_box_height = height;
        return this;
    }

    setHitBox(width: number, height: number): this {
        this.hit_box_width = width;
        this.hit_box_height = height;
        return this;
    }

    setEyeLevel(level: number): this {
        this.eye_level = level;
        return this;
    }

    setGravity(gravity: number): this {
        this.gravity = gravity;
        return this;
    }

    setJump(
        falloff: number,
        height: number,
        time: number,
        countMax?: number,
    ): this {
        this.jump_falloff = falloff;
        this.jump_height = height;
        this.jump_time = time;
        if (countMax !== undefined) {
            this.jump_count_max = countMax;
        }
        return this;
    }

    setMovementSpeed(speed: number): this {
        this.movement_speed = speed;
        return this;
    }

    setBoolean(bools: AttributeBoolean[]): this {
        this.boolean = bools;
        return this;
    }
}
