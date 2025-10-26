import { DatagenReturnData } from "../../index";
import {
    Item,
    ItemDrop,
    ItemSprite,
    ItemInventory,
    ItemDurability,
    ItemHarvest,
    ItemType,
    ItemComponent,
    ItemFunction,
} from "../items";

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
    private condition?: ItemTileCondition;

    constructor(id: string, amount?: number, chance?: number) {
        super(id, amount, chance);
    }

    setCondition(condition: ItemTileCondition) {
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
    private condition?: string | ItemTilePlacementCondition;
    private index?: string | number;

    setCondition(condition: string | ItemTilePlacementCondition) {
        this.condition = condition;

        return this;
    }

    setIndex(index: string | number) {
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

export default (
    id: string,
    type: ItemType,
    inventory: string | ItemInventory,
    properties?: ItemTileProperties | ItemTileProperties[],
    drop?: string | ItemTileDrop[],
    harvest?: ItemTileHarvest,
    placement?: string | ItemTilePlacement,
    sfx?: string | ItemTileSFX,
    components?: [
        {
            key: string;
            component: ItemComponent;
        },
    ],
    onUse?: ItemFunction[],
) => {
    class TileItem extends Item {
        private tile: {
            drop?: string | ItemTileDrop[];
            harvest?: string | ItemTileHarvest;
            placement?: string | ItemTilePlacement;
            sfx?: string | ItemTileSFX;
            components?: {
                [key: string]: ItemComponent;
            };
            on_use?: ItemFunction[];
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

        setTileDrop(drop?: string | ItemTileDrop[]) {
            if (drop) {
                this.tile.drop = drop;
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

        addOnUse(value: ItemFunction[]) {
            this.tile.on_use ??= value;

            return this;
        }
    }

    const tile = new TileItem(
        type,
        `phantasia:item/${id}`,
        inventory,
        properties,
    )
        .setTileDrop(drop)
        .setTileHarvest(harvest)
        .setTilePlacement(placement)
        .setTileSFX(sfx);

    components?.forEach(({ key, component }) =>
        tile.addComponent(key, component),
    );

    if (onUse) {
        tile.addOnUse(onUse);
    }

    return new DatagenReturnData(`generated/data/items/${id}.json`, tile);
};
