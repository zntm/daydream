import { Attribute } from "../attribute";
import { ItemDrop } from "./items";
import { readdirSync } from "fs";
import { join } from "path";

export enum CreatureHostilityType {
    Passive = "passive",
    Hostile = "hostile",
}

export enum CreatureMovementType {
    Ground = "ground",
    Liquid = "liquid",
    Air = "air",
}

export class Creature {
    private hp: number;
    private hostility_type: CreatureHostilityType;
    private movement_type: CreatureMovementType;
    private sprite: CreatureSprite | { [key: string]: CreatureSprite };
    private attribute: Attribute;
    private drops?: ItemDrop[];

    constructor(
        hp: number,
        hostilityType: CreatureHostilityType,
        movementType: CreatureMovementType,
        sprite: CreatureSprite | { [key: string]: CreatureSprite },
        attribute: Attribute,
    ) {
        this.hp = hp;
        this.hostility_type = hostilityType;
        this.movement_type = movementType;
        this.sprite = sprite;
        this.attribute = attribute;
    }

    setDrops(drops: ItemDrop[]) {
        this.drops = drops;

        return this;
    }
}

export class CreatureSpriteData {
    id: string;
    emissive?: string;

    constructor(id: string, emissive?: string) {
        this.id = id;
        this.emissive = emissive;
    }
}

export class CreatureSprite {
    idle: CreatureSpriteData;
    moving: CreatureSpriteData;

    constructor(idle: CreatureSpriteData, moving: CreatureSpriteData) {
        this.idle = idle;
        this.moving = moving;
    }
}

export default readdirSync(join(__dirname, "./creatures"))
    .map((type) => import.meta.require(`./creatures/${type}`).default)
    .filter((biome) => biome)
    .flat();
