import { Item } from "./Item";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";

export enum ItemAccessoryType {
    Helmet = "helmet",
    Breastplate = "breastplate",
    Leggings = "leggings",
    Accessory = "accessory",
}

interface AttributeModifier {
    attribute: string;
    modifier: unknown;
}

export class ItemAccessory {
    private type: ItemAccessoryType;
    private defense: number;
    private attributes?: AttributeModifier[];

    constructor(type: ItemAccessoryType, defense: number) {
        this.type = type;
        this.defense = defense;
    }

    addAttribute(attribute: string, modifier: unknown): this {
        this.attributes ??= [];
        this.attributes.push({ attribute, modifier });
        return this;
    }
}

/**
 * Base accessory item - armor pieces and accessories.
 */
export class Accessory extends Item {
    // @ts-ignore - override parent item
    protected item: {
        armor?: ItemAccessory;
        durability?: ItemDurability;
    } = {};

    constructor(sprite: string) {
        super(
            ItemType.Accessory,
            sprite,
            "#phantasia:item/generic/inventory_tool",
        );
    }

    setItemAccessory(armor: ItemAccessory): this {
        this.item.armor = armor;
        return this;
    }

    setItemDurability(durability: ItemDurability): this {
        this.item.durability = durability;
        return this;
    }

    addAttribute(attribute: string, modifier: unknown): this {
        this.item.armor?.addAttribute(attribute, modifier);
        return this;
    }
}

// Empty subclasses kept for semantic distinction and export compatibility
export class HelmetItem extends Accessory { }
export class BreastplateItem extends Accessory { }
export class LeggingsItem extends Accessory { }
export class AccessoryItem extends Accessory { }

// Factory functions for cleaner call sites
export const Helmet = (sprite: string) => new HelmetItem(sprite);
export const Breastplate = (sprite: string) => new BreastplateItem(sprite);
export const Leggings = (sprite: string) => new LeggingsItem(sprite);
