import { readdirSync } from "fs";
import { join } from "path";
import type { SmartValue } from "../index";
import type { Attribute } from "./attribute";
import {
    EntityPhysics,
    EntityPhysicsValue,
    EntityPhysicsValueType,
} from "./entity";
import type { ItemSprite } from "./items";

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
    IsFadeOut = "phantasia:is_fade_out",
}

export class Particle {
    private sprite: string | ItemSprite;
    private properties?: ParticleProperties[];
    private lifetime?: number | string | SmartValue;
    private physics?: EntityPhysics;
    private attribute?: Attribute;
    private on_collision?: PartileFunction;

    constructor(
        sprite: string | ItemSprite,
        properties?: ParticleProperties[],
    ) {
        this.sprite = sprite;
        this.properties = properties;
    }

    setLifetime(lifetime: number | string | SmartValue) {
        this.lifetime = lifetime;

        return this;
    }

    setPhysics(physics: EntityPhysics) {
        this.physics = physics;

        return this;
    }

    setAttribute(attribute: Attribute) {
        this.attribute = attribute;

        return this;
    }

    setOnCollision(on_collision: PartileFunction) {
        this.on_collision = on_collision;

        return this;
    }
}

export default readdirSync(join(__dirname, "./particles"))
    .map((file) => {
        try {
            return import.meta.require(`./particles/${file}`).default;
        } catch (e) {
            console.error(`Error loading particle file ${file}:`, e);
            return null;
        }
    })
    .filter((particle) => particle)
    .flat();
