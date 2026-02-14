import { DatagenReturnData, Attribute, EntityPhysics } from "../../../lib";
import { Projectile } from "../lib/Projectile";

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
];
