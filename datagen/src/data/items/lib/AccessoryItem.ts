import { Item } from "./Item";
import { ItemInventory } from "./ItemInventory";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";

export class ItemAccessory {
    private type: ItemAccessoryType;
    private defense: number;

    constructor(type: ItemAccessoryType, defense: number) {
        this.type = type;
        this.defense = defense;
    }
}

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

export class AccessoryItem extends Item {
    private item?: {
        armor?: ItemAccessory;
        durability?: ItemDurability;
    };

    constructor(
        id: string,
        armorType: ItemAccessoryType,
        armorDefense: number,
        durabilityAmount: number,
        durabilityBar: string,
    ) {
        super(ItemType.Tool, `phantasia:item/${id}`, "#phantasia:item/generic/inventory_tool");
        
        this.setItemAccessory(new ItemAccessory(armorType, armorDefense));
        this.setItemDurability(new ItemDurability(durabilityAmount, durabilityBar));
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
}
