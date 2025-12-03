import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Item } from "./Item";
import { ItemDrop } from "./ItemDrop";
import { ItemSprite } from "./ItemSprite";
import { ItemInventory } from "./ItemInventory";
import { ItemDurability } from "./ItemDurability";
import { ItemHarvest } from "./ItemHarvest";
import { ItemType } from "./ItemType";
import { ItemComponent } from "./ItemComponent";
import { ItemFunction } from "./ItemFunction";
import type { SmartValue } from "../../../lib/SmartValue";

export class ItemTileParticle {
    private colour: string | string[];
    private frequency: number | string;

    constructor(colour: string | string[], frequency: number | string) {
        this.colour = colour;
        this.frequency = frequency;
    }
}

export class ItemTileCondition {
    private id: string;
    private level?: number;

    constructor(id: string, level?: number) {
        this.id = id;
        this.level = level;
    }
}

export class ItemTileDropCondition {
    private index?: number;

    setIndex(index: number) {
        this.index = index;

        return this;
    }
}

export class ItemTileDrop extends ItemDrop {
    private condition?: ItemTileCondition | ItemTileDropCondition;

    constructor(id: string, amount?: number, chance?: number) {
        super(id, amount, chance);
    }

    setCondition(condition?: ItemTileCondition | ItemTileDropCondition) {
        this.condition = condition;

        return this;
    }
}

export class ItemTileHarvest extends ItemHarvest {
    private particle: ItemTileParticle;
    private condition?: ItemTileCondition;

    constructor(
        hardness: number,
        level: number,
        particle: ItemTileParticle,
        condition?: ItemTileCondition,
    ) {
        super(hardness, level);

        this.particle = particle;

        if (condition) {
            this.condition = condition;
        }
    }
}

export class ItemTileSFX {
    private id: string;
    private gain?: string | number;

    constructor(id: string, gain?: string | number) {
        this.id = id;
        this.gain = gain;
    }
}

export class ItemTilePlacement {
    private condition?: string | ItemTilePlacementCondition[];
    private index?: string | number | SmartValue;

    setCondition(condition: string | ItemTilePlacementCondition[]) {
        this.condition = condition;

        return this;
    }

    setIndex(index: string | number | SmartValue) {
        this.index = index;

        return this;
    }
}

export enum ItemTilePlacementConditionType {
    Every = "every",
    Some = "some",
}

export class ItemTilePlacementCondition {
    private type: ItemTilePlacementConditionType;
    private values: Array<
        | { condition: ItemTilePlacementCondition }
        | ItemTilePlacementConditionValue
    >;

    constructor(
        type: ItemTilePlacementConditionType,
        values: Array<
            | { condition: ItemTilePlacementCondition }
            | ItemTilePlacementConditionValue
        >,
    ) {
        this.type = type;
        this.values = values;
    }
}

export class ItemTilePlacementConditionValue {
    private xoffset: number;
    private yoffset: number;
    private z: string;
    private id?: string | string[];
    private type?: ItemType[];

    constructor(xoffset: number, yoffset: number, z: string) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.z = z;
    }

    setId(id: string | string[]) {
        this.id = id;

        return this;
    }

    setType(type: ItemType[]) {
        this.type = type;

        return this;
    }
}

export enum ItemTileProperties {
    CanMirror = "phantasia:can_mirror",
    CanFlip = "phantasia:can_flip",
    IsFoliage = "phantasia:is_foliage",
    IsTile = "phantasia:is_tile",
    IsWall = "phantasia:is_wall",
}

export class TileItem extends Item {
    private tile: {
        components?: string | { [key: string]: ItemComponent };
        drops?: string | ItemTileDrop[];
        harvest?: string | ItemTileHarvest;
        placement?: string | ItemTilePlacement;
        sfx?: string | ItemTileSFX;
        on_use?: ItemFunction[];
        on_random_tick?: ItemFunction[];
        light?: string;
        animation_type?: string;
    };

    constructor(
        type: ItemType,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: ItemTileProperties | ItemTileProperties[],
    ) {
        super(type, sprite, inventory, properties);

        this.tile = {};
    }

    setTileComponents(components?: string | { [key: string]: ItemComponent }) {
        if (components) {
            this.tile.components = components;
        }

        return this;
    }

    setTileDrops(drop?: string | ItemTileDrop[]) {
        if (drop) {
            this.tile.drops = drop;
        }

        return this;
    }

    setTileHarvest(harvest?: string | ItemTileHarvest) {
        if (harvest) {
            this.tile.harvest = harvest;
        }

        return this;
    }

    setTilePlacement(placement?: string | ItemTilePlacement) {
        if (placement) {
            this.tile.placement = placement;
        }

        return this;
    }

    setTileSFX(sfx?: string | ItemTileSFX) {
        if (sfx) {
            this.tile.sfx = sfx;
        }

        return this;
    }

    addComponent(key: string, value: ItemComponent) {
        this.tile.components ??= {};
        this.tile.components[key] = value;

        return this;
    }

    setTileLight(color: string) {
        this.tile.light = color;

        return this;
    }

    setAnimationType(type: string) {
        this.tile.animation_type = type;

        return this;
    }

    addOnRandomTick(functions: ItemFunction[]) {
        this.tile.on_random_tick ??= [];
        this.tile.on_random_tick.push(...functions);

        return this;
    }

    addOnUse(functions: ItemFunction[]) {
        this.tile.on_use ??= [];
        this.tile.on_use.push(...functions);

        return this;
    }
}
