import { DatagenReturnData } from "../index";

import consumableItem from "./items/consumableItem";
import woodItems from "./items/woodItems";

export class Item {
    public type: string;
    public sprite: string | ItemSprite;
    public inventory: string | ItemInventory;
    public item?: any;

    constructor(
        type: string,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
    ) {
        this.type = type;
        this.sprite = sprite;
        this.inventory = inventory;
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

export default [
    consumableItem(
        "apple",
        new ItemSprite(6, 7, 1),
        "#phantasia:item/generic/inventory_default",
        new ItemConsumable(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new ItemSoundEffect("phantasia:sound.eat"),
        ),
    ),
    ...woodItems("birch", new ItemSprite(12, 8), ["#4F5263", "#3E4051"]),
];
