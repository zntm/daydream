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

    setCollisionBox(width: number, height: number) {
        this.collision_box_width = width;
        this.collision_box_height = height;

        return this;
    }

    setHitBox(width: number, height: number) {
        this.hit_box_width = width;
        this.hit_box_height = height;

        return this;
    }

    setEyeLevel(level: number) {
        this.eye_level = level;

        return this;
    }

    setGravity(gravity: number) {
        this.gravity = gravity;

        return this;
    }

    setJump(
        jumpFalloff: number,
        jumpHeight: number,
        jumpTime: number,
        jumpCountMax?: number,
    ) {
        this.jump_falloff = jumpFalloff;
        this.jump_height = jumpHeight;
        this.jump_time = jumpTime;

        if (jumpCountMax !== undefined) {
            this.jump_count_max = jumpCountMax;
        }

        return this;
    }

    setMovementSpeed(speed: number) {
        this.movement_speed = speed;

        return this;
    }

    setBoolean(boolean: AttributeBoolean[]) {
        this.boolean = boolean;

        return this;
    }
}
