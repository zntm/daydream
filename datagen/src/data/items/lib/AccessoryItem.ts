import { Item } from "./Item";
import { ItemInventory } from "./ItemInventory";
import { ItemDurability } from "./ItemDurability";
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

    /**
     * Add an attribute modifier to the armor
     * @param attribute - Attribute to modify (e.g., "gravity", "movement_speed")
     * @param modifier - The EffectModifier to apply
     */
    addAttributeModifier(attribute: string, modifier: EffectModifier) {
        if (this.item?.armor) {
            this.item.armor.addAttribute(attribute, modifier);
        }
        return this;
    }
}
