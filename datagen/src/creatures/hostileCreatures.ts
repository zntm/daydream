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
        movementType: CreatureMovementType,
        sprite: string,
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
