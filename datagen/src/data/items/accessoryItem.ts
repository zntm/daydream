import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Item } from "./lib/Item";
import { ItemInventory } from "./lib/ItemInventory";
import { ItemDurability } from "./lib/ItemDurability";
import { ItemType } from "./lib/ItemType";
import { ItemHarvest } from "./lib/ItemHarvest";
import type { ItemTileProperties } from "./tileItem";

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

export default (
    id: string,
    armorType: ItemAccessoryType,
    armorDefense: number,
    durabilityAmount: number,
    durabilityBar: string,
) => {
    class AccessoryItem extends Item {
        private item?: {
            armor?: ItemAccessory;
            durability?: ItemDurability;
        };

        constructor(
            type: ItemType,
            sprite: string,
            inventory: string | ItemInventory,
        ) {
            super(type, sprite, inventory);
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

    return new DatagenReturnData(
        `generated/data/items/${id}.json`,
        new AccessoryItem(
            ItemType.Tool,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_tool",
        )
            .setItemAccessory(new ItemAccessory(armorType, armorDefense))
            .setItemDurability(
                new ItemDurability(durabilityAmount, durabilityBar),
            ),
    );
};
