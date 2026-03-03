import type { SmartValueValueType } from "../../../lib";
import { Item } from "./Item";
import type { ItemComponentData, ItemComponentType } from "./ItemComponent";
import { ItemDrop } from "./ItemDrop";
import { ItemHarvest } from "./ItemHarvest";
import { ItemScript } from "./ItemScript";
import type { ItemInventory } from "./ItemInventory";
import type { ItemParticle } from "./ItemParticle";
import { TileItemProperties } from "./ItemProperties";
import type { ItemSFX } from "./ItemSFX";
import type { ItemType } from "./ItemType";

export class TileItemAudioProperties {
    private lowpass: number;
    private reverb: number;

    constructor(lowpass: number, reverb: number) {
        this.lowpass = lowpass;
        this.reverb = reverb;
    }
}

export class TileItemCondition {
    private id: string;
    private level?: number;
    private index?: number;

    constructor(id: string, level?: number) {
        this.id = id;
        this.level = level;
    }

    setIndex(index?: number) {
        this.index = index;
    }
}

export class TileItemDrop extends ItemDrop {
    private condition?: TileItemCondition;

    constructor(id: string, amount?: number, chance?: number) {
        super(id, amount, chance);
    }

    setCondition(condition?: TileItemCondition) {
        this.condition = condition;

        return this;
    }
}

export class TileItemHarvest extends ItemHarvest {
    private particle: ItemParticle;
    private condition?: TileItemCondition;

    constructor(
        hardness: number | string,
        level: number | string,
        particle: ItemParticle,
        condition?: TileItemCondition,
    ) {
        super(hardness, level);

        this.particle = particle;

        if (condition) {
            this.condition = condition;
        }
    }

    setCondition(condition?: TileItemCondition) {
        this.condition = condition;

        return this;
    }
}

export class TileItemPlacement {
    private condition?:
        | string
        | TileItemPlacementCondition
        | TileItemPlacement[];
    private index?: string | number | SmartValueValueType;

    setCondition(
        condition: string | TileItemPlacementCondition | TileItemPlacement[],
    ) {
        this.condition = condition;

        return this;
    }

    setIndex(index: string | number | SmartValueValueType) {
        this.index = index;

        return this;
    }
}

export enum TileItemPlacementConditionType {
    Every = "every",
    Some = "some",
}

export class TileItemPlacementCondition {
    private type: TileItemPlacementConditionType;
    private values: Array<TileItemPlacement | TileItemPlacementConditionValue>;

    constructor(
        type: TileItemPlacementConditionType,
        values: Array<TileItemPlacement | TileItemPlacementConditionValue>,
    ) {
        this.type = type;
        this.values = values;
    }
}

export class TileItemPlacementConditionValue {
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

export class TileItem extends Item {
    private tile?: {
        components?: { [key: string]: ItemComponentData };
        drops?: string | TileItemDrop[];
        harvest?: string | TileItemHarvest;
        placement?: string | TileItemPlacement;
        sfx?: string | ItemSFX;
        audio_properties?: TileItemAudioProperties;
        on_use?: ItemScript[];
        on_random_tick?: ItemScript[];
        light?: string;
        animation_type?: string;
    };

    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: TileItemProperties[],
    ) {
        super(type, sprite, inventory, properties);
    }

    setTileDrops(drop?: string | TileItemDrop[]) {
        if (drop) {
            this.tile ??= {};
            this.tile.drops = drop;
        }

        return this;
    }

    setTileHarvest(harvest?: string | TileItemHarvest) {
        if (harvest) {
            this.tile ??= {};
            this.tile.harvest = harvest;
        }

        return this;
    }

    setTilePlacement(placement?: string | TileItemPlacement) {
        if (placement) {
            this.tile ??= {};
            this.tile.placement = placement;
        }

        return this;
    }

    setTileSFX(sfx?: string | ItemSFX) {
        if (sfx) {
            this.tile ??= {};
            this.tile.sfx = sfx;
        }

        return this;
    }

    setTileAudioProperties(audioProperties: TileItemAudioProperties) {
        this.tile ??= {};
        this.tile.audio_properties = audioProperties;

        return this;
    }

    addTileComponent(key: string, value: ItemComponentData) {
        this.tile ??= {};
        this.tile.components ??= {};
        this.tile.components[key] = value;

        return this;
    }

    setTileLight(color: string) {
        this.tile ??= {};
        this.tile.light = color;

        return this;
    }

    setAnimationType(type: string) {
        this.tile ??= {};
        this.tile.animation_type = type;

        return this;
    }

    setTileOnRandomTick(functions: ItemScript[]) {
        this.tile ??= {};
        this.tile.on_random_tick ??= [];
        this.tile.on_random_tick.push(...functions);

        return this;
    }

    addOnUse(functions: ItemScript[]) {
        this.tile ??= {};
        this.tile.on_use ??= [];
        this.tile.on_use.push(...functions);

        return this;
    }
}
