import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { SmartValueIntRandom } from "../../lib/SmartValue";
import { Attribute, AttributeBoolean } from "../../attribute";
import {
    Creature,
    CreatureHostilityType,
    CreatureMovementType,
    CreatureSprite,
    CreatureSpriteData,
} from "../creatures";
import { ItemDrop } from "../items";

class PassiveCreature extends Creature {
    constructor(
        hp: number,
        movementType: CreatureMovementType,
        sprite: CreatureSprite | { [key: string]: CreatureSprite },
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
            {
                black: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/idle/black",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/moving/black",
                    ),
                ),
                default: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/idle/default",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/moving/default",
                    ),
                ),
                spotted: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/idle/spotted",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/moving/spotted",
                    ),
                ),
                white: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/idle/white",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/rabbit/moving/white",
                    ),
                ),
            },
            new Attribute()
                .setCollisionBox(17, 17)
                .setHitBox(15, 16)
                .setEyeLevel(3)
                .setGravity(0.5)
                .setJump(2.2, 4.9, 11)
                .setMovementSpeed(0.4),
        )
            .setDrops([new ItemDrop("phantasia:raw_rabbit")])
            .setPredators(["phantasia:fox"]),
    ),
    new DatagenReturnData(
        "generated/data/creatures/chicken.json",
        new PassiveCreature(
            12,
            CreatureMovementType.Ground,
            {
                cold: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/idle/cold",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/moving/cold",
                    ),
                ),
                default: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/idle/default",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/moving/default",
                    ),
                ),
                warm: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/idle/warm",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/chicken/moving/warm",
                    ),
                ),
            },
            new Attribute()
                .setBoolean([AttributeBoolean.IsFallDamageResistant])
                .setCollisionBox(10, 16)
                .setHitBox(14, 15)
                .setEyeLevel(3)
                .setGravity(0.5)
                .setJump(2.2, 4.6, 10)
                .setMovementSpeed(0.4),
        ).setDrops([
            new ItemDrop("phantasia:raw_chicken"),
            new ItemDrop(
                "phantasia:feather",
                new SmartValueIntRandom(1, 3),
                0.7,
            ),
        ]),
    ),
    new DatagenReturnData(
        "generated/data/creatures/fox.json",
        new PassiveCreature(
            18,
            CreatureMovementType.Ground,
            {
                brown: new CreatureSprite(
                    new CreatureSpriteData("phantasia:creature/fox/idle/brown"),
                    new CreatureSpriteData(
                        "phantasia:creature/fox/moving/brown",
                    ),
                ),
                default: new CreatureSprite(
                    new CreatureSpriteData(
                        "phantasia:creature/fox/idle/default",
                    ),
                    new CreatureSpriteData(
                        "phantasia:creature/fox/moving/default",
                    ),
                ),
                snow: new CreatureSprite(
                    new CreatureSpriteData("phantasia:creature/fox/idle/snow"),
                    new CreatureSpriteData(
                        "phantasia:creature/fox/moving/snow",
                    ),
                ),
            },
            new Attribute()
                .setCollisionBox(22, 18)
                .setHitBox(22, 19)
                .setEyeLevel(3)
                .setGravity(0.5)
                .setJump(2.2, 4.9, 10)
                .setMovementSpeed(0.5),
        ).setContactDamage(3),
    ),
];
