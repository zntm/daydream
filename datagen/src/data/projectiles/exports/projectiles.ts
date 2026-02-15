import { DatagenReturnData, Attribute, EntityPhysics } from "../../../lib";
import { Projectile, ProjectileProperties } from "../lib/Projectile";

export default [
    new DatagenReturnData(
        "projectiles/melee_swing.json",
        new Projectile("phantasia:projectile/melee_swing")
            .setLifetime(0.25)
            .setPhysics(new EntityPhysics(14, 0))
            .setAttribute(
                new Attribute().setCollisionBox(32, 64).setHitBox(32, 64),
            ),
    ),
    new DatagenReturnData(
        "projectiles/arrow.json",
        new Projectile("phantasia:projectile/arrow", [
            ProjectileProperties.CanDestroyOnEntityCollision,
            ProjectileProperties.CanDestroyOnTileCollision,
        ])
            .setLifetime(3)
            .setPhysics(new EntityPhysics(12, 0))
            .setAttribute(
                new Attribute().setCollisionBox(8, 8).setHitBox(8, 8),
            ),
    ),
];
