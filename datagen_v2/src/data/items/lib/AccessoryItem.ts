import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import { ItemDurability } from "./ItemDurability";
import { ItemScript } from "./ItemScript";
import { ItemType } from "./ItemType";
import { EffectModifier } from "../../effects/lib/EffectModifier";

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

export class ItemAccessory {
    private type: ItemAccessoryType;
    private attributes?: { attribute: string; modifier: EffectModifier }[];

    constructor(type: ItemAccessoryType) {
        this.type = type;
    }

    addAttribute(attribute: string, modifier: EffectModifier) {
        this.attributes ??= [];
        this.attributes.push({ attribute, modifier });

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
