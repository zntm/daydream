import { Attribute } from "../../../lib";
import { ItemDrop } from "../../items/lib/ItemProperties";

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
        hp: number,
        hostilityType: CreatureHostilityType,
        movementType: CreatureMovementType,
<<<<<<< HEAD:datagen_new/src/data/creatures/lib/Creature.ts
        sprite: CreatureSprite | Record<string, CreatureSprite>,
=======
        sprite: CreatureSprite | { [key: string]: CreatureSprite },
>>>>>>> region:datagen/src/data/creatures/lib/Creature.ts
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

    setPredators(predators: string[]) {
        this.predators = predators;

        return this;
    }

    setProperties(properties: CreatureProperties[]) {
        this.properties = properties;

        return this;
    }

    setContactDamage(damage: number) {
        this.contact_damage = damage;

        return this;
    }
<<<<<<< HEAD:datagen_new/src/data/creatures/lib/Creature.ts

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
=======
>>>>>>> region:datagen/src/data/creatures/lib/Creature.ts
}
