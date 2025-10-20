import { DatagenReturnData } from "../../index";
import {
    Item,
    ItemSprite,
    ItemInventory,
    ItemDurability,
    ItemHarvest,
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

export class ItemTileDrop {
    private id: string;
    private amount?: number;
    private chance?: number;
    private condition?: ItemTileCondition;

    constructor(id: string, amount?: number, chance?: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
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
    }

    setIndex(index: string | number) {
        this.index = index;
    }
}

export class ItemTilePlacementCondition {
    private id: string;

    constructor(condition: string) {
        this.id = condition;
    }
}

export enum ItemTileProperties {
    CanMirror = "phantasia:can_mirror",
    CanFlip = "phantasia:can_flip",
    IsFoliage = "phantasia:is_foliage",
    IsTile = "phantasia:is_tile",
}

export default (
    id: string,
    type: string,
    inventory: string | ItemInventory,
    properties?: ItemTileProperties | ItemTileProperties[],
    drop?: string | ItemTileDrop[],
    harvest?: ItemTileHarvest,
    placement?: string | ItemTilePlacement,
    sfx?: string | ItemTileSFX,
) => {
    class TileItem extends Item {
        private tile: {
            drop?: string | ItemTileDrop[];
            harvest?: string | ItemTileHarvest;
            placement?: string | ItemTilePlacement;
            sfx?: string | ItemTileSFX;
        };

        constructor(
            type: string,
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
    }

    return new DatagenReturnData(
        `generated/data/items/${id}.json`,
        new TileItem(type, `phantasia:block/${id}`, inventory, properties)
            .setTileDrop(drop)
            .setTileHarvest(harvest)
            .setTilePlacement(placement)
            .setTileSFX(sfx),
    );
};
