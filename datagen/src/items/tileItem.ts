import { DatagenReturnData } from "../../index";
import { Item, ItemSprite, ItemInventory, ItemDurability } from "../items";

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

    constructor(id: string, amount?: number, chance?: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }
}

export class ItemTileHarvest {
    private hardness: number;
    private level: number;
    private particle: ItemTileParticle;
    private condition: ItemTileCondition;

    constructor(
        hardness: number,
        level: number,
        particle: ItemTileParticle,
        condition: ItemTileCondition,
    ) {
        this.hardness = hardness;
        this.level = level;
        this.particle = particle;
        this.condition = condition;
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

export default (
    id: string,
    type: string,
    sprite: string | ItemSprite,
    inventory: string | ItemInventory,
    drop: string | ItemTileDrop[],
    harvest: ItemTileHarvest,
    sfx: string | ItemTileSFX,
) => {
    class TileItem extends Item {
        private tile: {
            drop?: string | ItemTileDrop[];
            harvest?: string | ItemTileHarvest;
            sfx?: string | ItemTileSFX;
        };

        constructor(
            type: string,
            sprite: string | ItemSprite,
            inventory: string | ItemInventory,
        ) {
            super(type, sprite, inventory);

            this.tile = {};
        }

        setTileDrop(drop: string | ItemTileDrop[]) {
            this.tile.drop = drop;

            return this;
        }

        setTileHarvest(harvest: string | ItemTileHarvest) {
            this.tile.harvest = harvest;

            return this;
        }

        setTileSFX(sfx: string | ItemTileSFX) {
            this.tile.sfx = sfx;

            return this;
        }
    }

    return new DatagenReturnData(
        `generated/items/${id}.json`,
        new TileItem(type, sprite, inventory)
            .setTileDrop(drop)
            .setTileHarvest(harvest)
            .setTileSFX(sfx),
    );
};
