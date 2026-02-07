import { SmartValue } from "../../../lib/SmartValue";
import { Attribute } from "../../../lib/Attribute";
import { ItemDrop } from "../../items/lib";
import {
    Creature,
    CreatureMovementType,
    CreatureSprite,
    CreatureSpriteData,
    CreatureHostilityType,
    CreatureProperties,
} from "../lib/Creature";

class HostileCreature extends Creature {
    constructor(
        id: string,
        hp: number,
        movementType: CreatureMovementType,
        sprite: CreatureSprite | { [key: string]: CreatureSprite },
        attribute: Attribute
    ) {
        super(
            id,
            hp,
            CreatureHostilityType.Hostile,
            movementType,
            sprite,
            attribute
        );
    }
}

export default [
    // Zombie
    new HostileCreature(
        "zombie",
        36,
        CreatureMovementType.Ground,
        new CreatureSprite(
            new CreatureSpriteData("phantasia:creature/zombie/idle"),
            new CreatureSpriteData("phantasia:creature/zombie/moving")
        ),
        new Attribute()
            .setCollisionBox(16, 30)
            .setHitBox(18, 32)
            .setEyeLevel(8)
            .setGravity(0.5)
            .setJump(2.2, 4.9, 10)
            .setMovementSpeed(0.4)
    )
        .setDrops([
            new ItemDrop(
                "phantasia:rotten_flesh",
                SmartValue.IntRandom(1, 3),
                0.8
            ),
        ])
        .setProperties([CreatureProperties.IsHumanoid])
        .setContactDamage(4)
        .build(),
];
