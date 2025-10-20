import { DatagenReturnData } from "../index";

export class Item {
    public type: string;
    public sprite: string | ItemSprite;
    public inventory: string | ItemInventory;
    public properties?: any;

    constructor(
        type: string,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: any,
    ) {
        this.type = type;
        this.sprite = sprite;
        this.inventory = inventory;

        if (properties !== undefined) {
            this.properties = Array.isArray(properties)
                ? properties
                : [properties];
        }
    }
}

export class ItemSprite {
    private xoffset: number;
    private yoffset: number;
    private length: number;

    constructor(xoffset: number, yoffset: number, length: number = 1) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.length = length;
    }
}

export class ItemConsumable {
    private hp: number;
    private saturation: number;
    private cooldown: any;
    private sfx: any;

    constructor(hp: number, saturation: number, cooldown: any, sfx: any) {
        this.hp = hp;
        this.saturation = saturation;
        this.cooldown = cooldown;
        this.sfx = sfx;
    }
}

export class ItemCooldown {
    private id: string;
    private second: number;

    constructor(id: string, second: number) {
        this.id = id;
        this.second = second;
    }
}

export class ItemInventory {}

export class ItemHarvest {
    private hardness: number;
    private level: number;

    constructor(hardness: number, level: number) {
        this.hardness = hardness;
        this.level = level;
    }
}

export class ItemSoundEffect {
    private id: string;
    private gain?: number;

    constructor(id: string, gain?: number) {
        this.id = id;

        if (gain !== undefined) {
            this.gain = gain;
        }
    }
}

export class ItemDurability {
    private amount: number;
    private bar: string;

    constructor(amount: number, bar: string) {
        this.amount = amount;
        this.bar = bar;
    }
}

export enum ItemType {
    Default = "default",
    Solid = "solid",
    Untouchable = "untouchable",
    Tool = "tool",
}

const { default: consumableItem } = import.meta.require(
    "./items/consumableItem",
);
const { default: woodItems } = import.meta.require("./items/woodItems");

export default [
    consumableItem(
        "apple",
        "#phantasia:item/generic/inventory_default",
        new ItemConsumable(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new ItemSoundEffect("phantasia:sound.eat"),
        ),
    ),
    ...woodItems(
        "birch",
        ["#051417", "#041013"],
        ["#4F5263", "#3E4051"],
        "#phantasia:tile/particle_colour/plank_birch",
    ),
    ...woodItems(
        "oak",
        ["#122D2B", "#0B2021"],
        ["#3B160A", "#2D0B04"],
        "#phantasia:tile/particle_colour/plank_oak",
    ),
    ...woodItems(
        "pine",
        ["#122D2B", "#0B2021"],
        ["#381D1E", "#301A1C"],
        "#phantasia:tile/particle_colour/plank_pine",
    ),
];
