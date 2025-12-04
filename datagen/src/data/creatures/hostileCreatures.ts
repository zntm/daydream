import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Attribute, AttributeBoolean } from "../../attribute";
import {
    Creature,
    CreatureHostilityType,
    CreatureMovementType,
    CreatureSprite,
    CreatureSpriteData,
} from "../creatures";
import { ItemDrop } from "../items";
import { SmartValueIntRandom } from "../../lib/SmartValue";

class HostileCreature extends Creature {
    constructor(
        hp: number,
        movementType: CreatureMovementType,
        sprite: CreatureSprite | { [key: string]: CreatureSprite },
        attribute: Attribute,
    ) {
        super(
            hp,
            CreatureHostilityType.Hostile,
            movementType,
            sprite,
            attribute,
        );
    }
}

export default [
    new DatagenReturnData(
        "generated/data/creatures/zombie.json",
        new HostileCreature(
            36,
            CreatureMovementType.Ground,
            new CreatureSprite(
                new CreatureSpriteData("phantasia:creature/zombie/idle"),
                new CreatureSpriteData("phantasia:creature/zombie/moving"),
            ),
            new Attribute()
                .setCollisionBox(16, 30)
                .setHitBox(18, 32)
                .setEyeLevel(8)
                .setGravity(0.5)
                .setJump(2.2, 5.9, 10)
                .setMovementSpeed(0.4),
        ).setDrops([
            new ItemDrop(
                "phantasia:rotten_flesh",
                new SmartValueIntRandom(1, 3),
                0.8,
            ),
        ]),
    ),
];
