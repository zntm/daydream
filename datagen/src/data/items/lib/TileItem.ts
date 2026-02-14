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

export class TileItemParticle {
    private colour: string | string[];
    private frequency: number | string;

    constructor(colour: string | string[], frequency: number | string) {
        this.colour = colour;
        this.frequency = frequency;
    }
}

export class TileItemCondition {
    private id: string;
    private level?: number;

    constructor(id: string, level?: number) {
        this.id = id;
        this.level = level;
    }
}

export class TileItemDropCondition {
    private index?: number;

    setIndex(index: number) {
        this.index = index;

        return this;
    }
}

export class TileItemDrop extends ItemDrop {
    private condition?: TileItemCondition | TileItemDropCondition;

    constructor(id: string, amount?: number, chance?: number) {
        super(id, amount, chance);
    }

    setCondition(condition?: TileItemCondition | TileItemDropCondition) {
        this.condition = condition;

        return this;
    }
}

export class TileItemHarvest extends ItemHarvest {
    private particle: TileItemParticle;
    private condition?: TileItemCondition;

    constructor(
        hardness: number,
        level: number,
        particle: TileItemParticle,
        condition?: TileItemCondition,
    ) {
        super(hardness, level);

        this.particle = particle;

        if (condition) {
            this.condition = condition;
        }
    }
}

export class ItemSFX {
    private id: string;
    private gain?: string | number;

    constructor(id: string, gain?: string | number) {
        this.id = id;
        this.gain = gain;
    }
}

export class ItemAudioProperties {
    private lowpass: number;
    private reverb: number;

    constructor(lowpass: number, reverb: number) {
        this.lowpass = lowpass;
        this.reverb = reverb;
    }
}

export class TileItemPlacement {
    private condition?:
        | string
        | TileItemPlacementCondition
        | TileItemPlacementCondition[];
    private index?: string | number | SmartValue;

    setCondition(
        condition:
            | string
            | TileItemPlacementCondition
            | TileItemPlacementCondition[],
    ) {
        this.condition = condition;

        return this;
    }

    setIndex(index: string | number | SmartValue) {
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
    private values: Array<
        | { condition: TileItemPlacementCondition }
        | TileItemPlacementConditionValue
    >;

    constructor(
        type: TileItemPlacementConditionType,
        values: Array<
            | { condition: TileItemPlacementCondition }
            | TileItemPlacementConditionValue
        >,
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

export enum TileItemProperties {
    CanMirror = "phantasia:can_mirror",
    CanFlip = "phantasia:can_flip",
    IsFoliage = "phantasia:is_foliage",
    IsLiquid = "phantasia:is_liquid",
    IsTile = "phantasia:is_tile",
    IsWall = "phantasia:is_wall",
}

export class TileItem extends Item {
    private tile: {
        components?: string | { [key: string]: ItemComponent };
        drops?: string | TileItemDrop[];
        harvest?: string | TileItemHarvest;
        placement?: string | TileItemPlacement;
        sfx?: string | ItemSFX;
        audio_properties?: ItemAudioProperties;
        on_use?: ItemFunction[];
        on_random_tick?: ItemFunction[];
        light?: string;
        animation_type?: string;
    };

    constructor(
        type: ItemType,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: TileItemProperties | TileItemProperties[],
    ) {
        super(type, sprite, inventory, properties);

        this.tile = {};
    }

    setTileDrops(drop?: string | TileItemDrop[]) {
        if (drop) {
            this.tile.drops = drop;
        }

        return this;
    }

    setTileHarvest(harvest?: string | TileItemHarvest) {
        if (harvest) {
            this.tile.harvest = harvest;
        }

        return this;
    }

    setTilePlacement(placement?: string | TileItemPlacement) {
        if (placement) {
            this.tile.placement = placement;
        }

        return this;
    }

    setTileSFX(sfx?: string | ItemSFX) {
        if (sfx) {
            this.tile.sfx = sfx;
        }

        return this;
    }

    setAudioProperties(lowpass: number, reverb: number) {
        this.tile.audio_properties = new ItemAudioProperties(lowpass, reverb);

        return this;
    }

    addComponent(key: string, value: ItemComponent) {
        if (typeof this.tile.components === "string") {
            this.tile.components = {};
        }
        this.tile.components ??= {};
        (this.tile.components as { [key: string]: ItemComponent })[key] = value;

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
