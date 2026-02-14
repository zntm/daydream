import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import { ItemDurability } from "./ItemDurability";
import type { ItemScript } from "./ItemScript";
import { ItemType } from "./ItemType";
import { EffectModifier } from "../../effects/lib/EffectModifier";

export class ItemAccessory {
    private type: ItemAccessoryType;
    private defense: number;
    private attributes?: { attribute: string; modifier: EffectModifier }[];

    constructor(type: ItemAccessoryType, defense: number) {
        this.type = type;
        this.defense = defense;
    }

    addAttribute(attribute: string, modifier: EffectModifier) {
        this.attributes ??= [];
        this.attributes.push({ attribute, modifier });
        return this;
    }
}

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

export class AccessoryItem extends Item {
    protected override item?: {
        armor?: ItemAccessory;
        durability?: ItemDurability;
        components?: { [key: string]: ItemComponentData };
        on_use?: ItemScript[];
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

    addAttributeModifier(attribute: string, modifier: EffectModifier) {
        if (this.item?.armor) {
            this.item.armor.addAttribute(attribute, modifier);
        }
        return this;
    }
}
