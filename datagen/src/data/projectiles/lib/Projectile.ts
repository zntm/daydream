import { Attribute, EntityPhysics, type SmartValue } from "../../../lib";

export enum ProjectileProperties {
    CanDestroyOnEntityCollision = "phantasia:can_destroy_on_entity_collision",
    CanDestroyOnTileCollision = "phantasia:can_destroy_on_tile_collision",
    HasStretchAnimation = "phantasia:has_stretch_animation",
}

export class Projectile {
    private sprite: string | any;
    private properties?: ProjectileProperties[];
    private lifetime?: number | string | SmartValue;
    private physics?: EntityPhysics;
    private attribute?: Attribute;
    private on_shoot?: any[];
    private on_land?: any[];
    private on_hit_entity?: any[];
    private on_hit_tile?: any[];
    private particles?: any[];

    constructor(
        sprite: string | any,
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

    private _ensureAtPrefix(hook: any[]) {
        return hook.map(h => {
            if (typeof h === 'object' && h.id && !h.id.startsWith('@')) {
                return { ...h, id: '@' + h.id };
            }
            return h;
        });
    }

    setOnShoot(on_shoot: any[]) {
        this.on_shoot = this._ensureAtPrefix(on_shoot);

        return this;
    }

    setOnLand(on_land: any[]) {
        this.on_land = this._ensureAtPrefix(on_land);

        return this;
    }

    setOnHitEntity(on_hit_entity: any[]) {
        this.on_hit_entity = this._ensureAtPrefix(on_hit_entity);

        return this;
    }

    setOnHitTile(on_hit_tile: any[]) {
        this.on_hit_tile = this._ensureAtPrefix(on_hit_tile);

        return this;
    }

    setParticles(particles: any[]) {
        this.particles = particles;

        return this;
    }
}
