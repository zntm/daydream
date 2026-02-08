import { Item } from "./Item";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

export class ItemAccessory {
    private type: ItemAccessoryType;
    private defense: number;
    private attributes?: { attribute: string; modifier: any }[];

    constructor(type: ItemAccessoryType, defense: number) {
        this.type = type;
        this.defense = defense;
    }

    addAttribute(attribute: string, modifier: any) {
        this.attributes ??= [];
        this.attributes.push({ attribute, modifier });
        return this;
    }
}

export abstract class Accessory extends Item {
    // @ts-ignore
    protected item?: {
        armor?: ItemAccessory;
        durability?: ItemDurability;
    };

    constructor(id: string) {
        super(
            ItemType.Accessory,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_tool",
        );
    }

    setItemAccessory(armor: ItemAccessory) {
        this.item ??= {};
        this.item.armor = armor;

        return this;
    }

    setItemDurability(durability: ItemDurability) {
        this.item ??= {};
        this.item.durability = durability;

        return this;
    }

    addAttribute(attribute: string, modifier: any) {
        if (this.item?.armor) {
            this.item.armor.addAttribute(attribute, modifier);
        }
        return this;
    }
}

export class HelmetItem extends Accessory {
    constructor(id: string) {
        super(id);
    }
}

export class BreastplateItem extends Accessory {
    constructor(id: string) {
        super(id);
    }
}

export class LeggingsItem extends Accessory {
    constructor(id: string) {
        super(id);
    }
}

export class AccessoryItem extends Accessory {
    constructor(id: string) {
        super(id);
    }
}