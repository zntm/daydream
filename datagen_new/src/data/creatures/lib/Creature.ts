import { DatagenReturnData } from "../../../lib";
import { Attribute } from "../../../lib/Attribute";
import { ItemDrop } from "../../items/lib";

export enum CreatureHostilityType {
    Passive = "passive",
    Hostile = "hostile",
}

export enum CreatureMovementType {
    Ground = "ground",
    Liquid = "liquid",
    Air = "air",
}

export enum CreatureProperties {
    IsHumanoid = "phantasia:is_humanoid",
}

// Keep as class for export compatibility
export class CreatureSpriteData {
    id: string;
    emissive?: string;

    constructor(id: string, emissive?: string) {
        this.id = id;
        if (emissive) this.emissive = emissive;
    }
}

// Keep as class for export compatibility
export class CreatureSprite {
    idle: CreatureSpriteData;
    moving: CreatureSpriteData;

    constructor(idle: CreatureSpriteData, moving: CreatureSpriteData) {
        this.idle = idle;
        this.moving = moving;
    }
}

// Factory functions for cleaner call sites
export const sprite = (id: string, emissive?: string) =>
    new CreatureSpriteData(id, emissive);
export const sprites = (idle: CreatureSpriteData, moving: CreatureSpriteData) =>
    new CreatureSprite(idle, moving);

export class Creature {
    private id: string;
    private hp: number;
    private hostility_type: CreatureHostilityType;
    private movement_type: CreatureMovementType;
    private sprite: CreatureSprite | Record<string, CreatureSprite>;
    private attribute: Attribute;
    private drops?: ItemDrop[];
    private predators?: string[];
    private properties?: CreatureProperties[];
    private contact_damage?: number;

    constructor(
        id: string,
        hp: number,
        hostilityType: CreatureHostilityType,
        movementType: CreatureMovementType,
        sprite: CreatureSprite | Record<string, CreatureSprite>,
        attribute: Attribute,
    ) {
        this.id = id;
        this.hp = hp;
        this.hostility_type = hostilityType;
        this.movement_type = movementType;
        this.sprite = sprite;
        this.attribute = attribute;
    }

    setDrops(drops: ItemDrop[]): this {
        this.drops = drops;
        return this;
    }

    setPredators(predators: string[]): this {
        this.predators = predators;
        return this;
    }

    setProperties(properties: CreatureProperties[]): this {
        this.properties = properties;
        return this;
    }

    setContactDamage(damage: number): this {
        this.contact_damage = damage;
        return this;
    }

    build(): DatagenReturnData {
        const data: Record<string, unknown> = {
            hp: this.hp,
            hostility_type: this.hostility_type,
            movement_type: this.movement_type,
            sprite: this.sprite,
            attribute: this.attribute,
        };

        if (this.drops) data.drops = this.drops;
        if (this.predators) data.predators = this.predators;
        if (this.properties) data.properties = this.properties;
        if (this.contact_damage !== undefined)
            data.contact_damage = this.contact_damage;

        return new DatagenReturnData(`${this.id}.json`, data);
    }
}
