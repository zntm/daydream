import { Attribute, EntityPhysics, type SmartValue } from "../../../lib";
import type { ItemSprite } from "../../items/lib/ItemProperties";

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
