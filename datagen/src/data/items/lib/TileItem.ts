import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import { ItemDrop } from "./ItemDrop";
import { ItemScript } from "./ItemScript";
import { ItemHarvest } from "./ItemHarvest";
import type { ItemInventory } from "./ItemInventory";
import { ItemParticle } from "./ItemParticle";
import { TileItemProperties } from "./ItemProperties";
import { ItemType } from "./ItemType";

export { ItemParticle };

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
    private index?: string | number | any;

    setCondition(
        condition: string | TileItemPlacementCondition | TileItemPlacement[],
    ) {
        this.condition = condition;

        return this;
    }

    setIndex(index: string | number | any) {
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
    protected override item?: {
        components?: { [key: string]: ItemComponentData };
        on_use?: ItemScript[];
        tile?: {
            components?: { [key: string]: ItemComponentData };
            drops?: string | TileItemDrop[];
            harvest?: string | TileItemHarvest;
            placement?: string | TileItemPlacement;
            sfx?: string;
            audio_properties?: TileItemAudioProperties;
            on_use?: ItemScript[];
            on_random_tick?: ItemScript[];
            light?: string;
            animation_type?: string;
        };
    } = {};

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
            this.item ??= {};
            this.item.tile ??= {};
            this.item.tile.drops = drop;
        }

        return this;
    }

    setTileHarvest(harvest?: string | TileItemHarvest) {
        if (harvest) {
            this.item ??= {};
            this.item.tile ??= {};
            this.item.tile.harvest = harvest;
        }

        return this;
    }

    setTilePlacement(placement?: string | TileItemPlacement) {
        if (placement) {
            this.item ??= {};
            this.item.tile ??= {};
            this.item.tile.placement = placement;
        }

        return this;
    }

    setTileSFX(sfx?: string) {
        if (sfx) {
            this.item ??= {};
            this.item.tile ??= {};
            this.item.tile.sfx = sfx;
        }

        return this;
    }

    setTileAudioProperties(audioProperties: TileItemAudioProperties) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.audio_properties = audioProperties;

        return this;
    }

    addTileComponent(key: string, value: ItemComponentData) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.components ??= {};
        this.item.tile.components[key] = value;

        return this;
    }

    setTileLight(color: string) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.light = color;

        return this;
    }

    setAnimationType(type: string) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.animation_type = type;

        return this;
    }

    setTileOnRandomTick(functions: ItemScript[]) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.on_random_tick ??= [];
        this.item.tile.on_random_tick.push(...functions);

        return this;
    }

    addOnUse(functions: ItemScript[]) {
        this.item ??= {};
        this.item.tile ??= {};
        this.item.tile.on_use ??= [];
        this.item.tile.on_use.push(...functions);

        return this;
    }
}
