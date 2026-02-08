import type { SmartValueValueType } from "../../../lib";
import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import { ItemDrop } from "./ItemDrop";
import { ItemHarvest } from "./ItemHarvest";
import type { ItemInventory } from "./ItemInventory";
import type { ItemParticle } from "./ItemParticle";
import { TileItemProperties } from "./ItemProperties";
import { ItemScript } from "./ItemScript";
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
        if (level !== undefined) this.level = level;
    }

    setIndex(index?: number): this {
        this.index = index;
        return this;
    }
}

export class TileItemDrop extends ItemDrop {
    private condition?: TileItemCondition;

    constructor(id: string, amount?: number, chance?: number) {
        super(id, amount, chance);
    }

    setCondition(condition?: TileItemCondition): this {
        if (condition) this.condition = condition;
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
        if (condition) this.condition = condition;
    }

    setCondition(condition?: TileItemCondition): this {
        if (condition) this.condition = condition;
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
    ): this {
        this.condition = condition;
        return this;
    }

    setIndex(index: string | number | SmartValueValueType): this {
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

    setId(id: string | string[]): this {
        this.id = id;
        return this;
    }

    setType(type: ItemType[]): this {
        this.type = type;
        return this;
    }
}

/**
 * TileItem - items that exist as tiles in the world (blocks, decorations, etc.)
 */
export class TileItem extends Item {
    private tile: {
        components?: Record<string, ItemComponentData>;
        drops?: string | TileItemDrop[];
        harvest?: string | TileItemHarvest;
        placement?: string | TileItemPlacement;
        sfx?: string | ItemSFX;
        audio_properties?: TileItemAudioProperties;
        on_use?: ItemScript[];
        on_random_tick?: ItemScript[];
        light?: string;
        animation_type?: string;
    } = {};

    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: TileItemProperties[],
    ) {
        super(type, sprite, inventory, properties);
    }

    setTileDrops(drop?: string | TileItemDrop[]): this {
        if (drop) this.tile.drops = drop;
        return this;
    }

    setTileHarvest(harvest?: string | TileItemHarvest): this {
        if (harvest) this.tile.harvest = harvest;
        return this;
    }

    setTilePlacement(placement?: string | TileItemPlacement): this {
        if (placement) this.tile.placement = placement;
        return this;
    }

    setTileSFX(sfx?: string | ItemSFX): this {
        if (sfx) this.tile.sfx = sfx;
        return this;
    }

    setTileAudioProperties(audioProperties: TileItemAudioProperties): this {
        this.tile.audio_properties = audioProperties;
        return this;
    }

    addTileComponent(key: string, value: ItemComponentData): this {
        this.tile.components ??= {};
        this.tile.components[key] = value;
        return this;
    }

    setTileLight(color: string): this {
        this.tile.light = color;
        return this;
    }

    setAnimationType(type: string): this {
        this.tile.animation_type = type;
        return this;
    }

    setTileOnRandomTick(functions: ItemScript[]): this {
        this.tile.on_random_tick = [
            ...(this.tile.on_random_tick ?? []),
            ...functions,
        ];
        return this;
    }

    addOnUse(functions: ItemScript[]): this {
        this.tile.on_use = [...(this.tile.on_use ?? []), ...functions];
        return this;
    }
}
