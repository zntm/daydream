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

    setIndex(index?: number): TileItemCondition {
        this.index = index;

        return this;
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
    // @ts-ignore
    private item: {
        tile?: {
            components?: { [key: string]: ItemComponentData };
            drops?: string | TileItemDrop[];
            falling?: { enabled?: boolean; delay?: number; gravity?: number };
            harvest?: string | TileItemHarvest;
            placement?: string | TileItemPlacement;
            sfx?: string | ItemSFX;
            audio_properties?: TileItemAudioProperties;
            on_use?: ItemScript[];
            light?: string;
            animation_type?: string;
            on_stay?: ItemScript[];
            on_random_tick?: ItemScript[];
        }
    }

    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: TileItemProperties[],
    ) {
        super(type, sprite, inventory, properties);

        this.item = {
            tile: {}
        }
    }

    setTileDrops(drop?: string | TileItemDrop[]) {
        if (drop) {
            this.item.tile ??= {};
            this.item.tile.drops = drop;
        }

        return this;
    }

    setTileHarvest(harvest?: string | TileItemHarvest) {
        if (harvest) {
            this.item.tile ??= {};
            this.item.tile.harvest = harvest;
        }

        return this;
    }

    setTilePlacement(placement?: string | TileItemPlacement) {
        if (placement) {
            this.item.tile ??= {};
            this.item.tile.placement = placement;
        }

        return this;
    }

    setTileSFX(sfx?: string | ItemSFX) {
        if (sfx) {
            this.item.tile ??= {};
            this.item.tile.sfx = sfx;
        }

        return this;
    }

    setTileAudioProperties(audioProperties: TileItemAudioProperties) {
        this.item.tile ??= {};
        this.item.tile.audio_properties = audioProperties;

        return this;
    }

    addTileComponent(key: string, value: ItemComponentData) {
        this.item.tile ??= {};
        this.item.tile.components ??= {};
        this.item.tile.components[key] = value;

        return this;
    }

    setTileLight(color: string) {
        this.item.tile ??= {};
        this.item.tile.light = color;

        return this;
    }

    setTileFalling(delay?: number, gravity?: number) {
        this.item.tile ??= {};
        this.item.tile.falling = { enabled: true };

        if (delay !== undefined) {
            this.item.tile.falling.delay = delay;
        }

        if (gravity !== undefined) {
            this.item.tile.falling.gravity = gravity;
        }

        return this;
    }

    setAnimationType(type: string) {
        this.item.tile ??= {};
        this.item.tile.animation_type = type;

        return this;
    }

    setTileOnRandomTick(functions: ItemScript[]) {
        this.item.tile ??= {};
        this.item.tile.on_random_tick ??= [];
        this.item.tile.on_random_tick.push(...functions);

        return this;
    }

    setTileOnStay(functions: ItemScript[]) {
        this.item.tile ??= {};
        this.item.tile.on_stay ??= [];
        this.item.tile.on_stay.push(...functions);

        return this;
    }

    addOnUse(functions: ItemScript[]) {
        this.item.tile ??= {};
        this.item.tile.on_use ??= [];
        this.item.tile.on_use.push(...functions);

        return this;
    }
}
