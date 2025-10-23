import {
    DatagenReturnData,
    SmartValue,
    SmartValueRandom,
    SmartValueType,
} from "../../index";
import { Attribute, AttributeBoolean } from "../attribute";
import {
    Creature,
    CreatureHostilityType,
    CreatureMovementType,
} from "../creatures";
import { ItemDrop } from "../items";

class HostileCreature extends Creature {
    constructor(
        hp: number,
        hostilityType: CreatureHostilityType,
        movementType: CreatureMovementType,
        sprite: string,
        attribute: Attribute,
    ) {
        super(hp, hostilityType, movementType, sprite, attribute);
    }
}

export default [
    new DatagenReturnData(
        "generated/assets/sprites/creature/zombie.json",
        new HostileCreature(
            36,
            CreatureHostilityType.Passive,
            CreatureMovementType.Ground,
            "phantasia:creature/zombie",
            new Attribute()
                .setCollisionBox(16, 30)
                .setHitBox(18, 32)
                .setEyeLevel(8)
                .setGravity(0.5)
                .setJump(2.2, 5.9, 10)
                .setMovementSpeed(0.4),
        ),
    ),
];
