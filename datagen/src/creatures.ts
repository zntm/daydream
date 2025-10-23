import { Attribute } from "./attribute";
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
    private sprite: string;
    private attribute: Attribute;
    private drops?: ItemDrop[];

    constructor(
        hp: number,
        hostilityType: CreatureHostilityType,
        movementType: CreatureMovementType,
        sprite: string,
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

export default readdirSync(join(__dirname, "./creatures"))
    .map((type) => import.meta.require(`./creatures/${type}`).default)
    .filter((biome) => biome)
    .flat();
