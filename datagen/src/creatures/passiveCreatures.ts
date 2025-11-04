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

class PassiveCreature extends Creature {
    constructor(
        hp: number,
        movementType: CreatureMovementType,
        sprite: any,
        attribute: Attribute,
    ) {
        super(
            hp,
            CreatureHostilityType.Passive,
            movementType,
            sprite,
            attribute,
        );
    }
}

export default [
    new DatagenReturnData(
        "generated/data/creatures/rabbit.json",
        new PassiveCreature(
            12,
            CreatureMovementType.Ground,
            "phantasia:creature/rabbit",
            new Attribute()
                .setCollisionBox(17, 17)
                .setHitBox(15, 16)
                .setEyeLevel(3)
                .setGravity(0.5)
                .setJump(2.2, 4.9, 11)
                .setMovementSpeed(0.4),
        ).setDrops([new ItemDrop("phantasia:raw_rabbit")]),
    ),
    new DatagenReturnData(
        "generated/data/creatures/chicken.json",
        new PassiveCreature(
            12,
            CreatureMovementType.Ground,
            "phantasia:creature/chicken",
            new Attribute()
                .setBoolean([AttributeBoolean.IsFallDamageResistant])
                .setCollisionBox(10, 16)
                .setHitBox(14, 15)
                .setEyeLevel(3)
                .setGravity(0.3)
                .setJump(2.2, 4.6, 10)
                .setMovementSpeed(0.4),
        ).setDrops([
            new ItemDrop("phantasia:raw_chicken"),
            new ItemDrop(
                "phantasia:feather",
                new SmartValue(
                    SmartValueType.IntRandom,
                    new SmartValueRandom(1, 3),
                ),
                0.7,
            ),
        ]),
    ),
    new DatagenReturnData(
        "generated/data/sprites/creature/fox.json",
        new PassiveCreature(
            18,
            CreatureMovementType.Ground,
            "phantasia:creature/fox",
            new Attribute()
                .setCollisionBox(22, 18)
                .setHitBox(22, 19)
                .setEyeLevel(3)
                .setGravity(0.3)
                .setJump(2.2, 5.9, 10)
                .setMovementSpeed(0.5),
        ),
    ),
];
