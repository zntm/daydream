import { DatagenReturnData, SmartValue } from "../index";
import { Attribute } from "./attribute";
import type { ItemSprite } from "./items";
import {
    EntityPhysics,
    EntityPhysicsValue,
    EntityPhysicsValueType,
} from "./entity";

export enum ProjectileProperties {
    CanDestroyOnEntityCollision = "phantasia:can_destroy_on_entity_collision",
    CanDestroyOnTileCollision = "phantasia:can_destroy_on_tile_collision",
    HasStretchAnimation = "phantasia:has_stretch_animation",
}

export class Projectile {
    private sprite: string | ItemSprite;
    private properties?: ProjectileProperties[];
    private lifetime?: number | string | SmartValue;
    private physics?: EntityPhysics;
    private attribute?: Attribute;

    constructor(
        sprite: string | ItemSprite,
        properties?: ProjectileProperties[],
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
}

export default [
    new DatagenReturnData(
        "generated/data/projectiles/melee_swing.json",
        new Projectile("phantasia:projectile/melee_swing")
            .setLifetime(0.25)
            .setPhysics(new EntityPhysics(14, 0))
            .setAttribute(
                new Attribute().setCollisionBox(32, 64).setHitBox(32, 64),
            ),
    ),
];
