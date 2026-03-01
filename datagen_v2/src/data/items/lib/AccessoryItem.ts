import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import { ItemDurability } from "./ItemDurability";
import { ItemScript } from "./ItemScript";
import { ItemType } from "./ItemType";
import { Attribute } from "../../../lib";

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

export class ItemAccessory {
    private type: ItemAccessoryType;
    private attribute?: Attribute;

    constructor(type: ItemAccessoryType) {
        this.type = type;
    }

    setAttribute(attribute: Attribute) {
        this.attribute = attribute;

        return this;
    }
}

export class AccessoryItem extends Item {
    declare protected item?: {
        accessory?: ItemAccessory;
        durability?: ItemDurability;
        components?: { [key: string]: ItemComponentData };
        on_use?: ItemScript[];
    };

    constructor(
        sprite: string,
        accessory: ItemAccessory,
        durability: ItemDurability,
    ) {
        super(
            ItemType.Accessory,
            sprite,
            "#phantasia:item/generic/inventory_tool",
        );

        this.item = {
            accessory,
            durability,
        };
    }
}
