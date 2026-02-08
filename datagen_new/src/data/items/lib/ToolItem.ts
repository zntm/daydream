import { Item, ItemDurability, ItemHarvest, ItemSkill, ItemType } from "./";

/**
 * Tool item - weapons and tools with damage, durability, harvest, and skill properties.
 */
export class ToolItem extends Item {
    // @ts-ignore - override parent item with tool-specific fields
    protected item: {
        damage?: number;
        harvest?: ItemHarvest;
        durability?: ItemDurability;
        skill?: ItemSkill;
    } = {};

    constructor(sprite: string) {
        super(ItemType.Tool, sprite, "#phantasia:item/generic/inventory_tool");
    }

    setDamage(damage: number): this {
        this.item.damage = damage;
        return this;
    }

    setItemDurability(durability: ItemDurability): this {
        this.item.durability = durability;
        return this;
    }

    setItemHarvest(harvest: ItemHarvest): this {
        this.item.harvest = harvest;
        return this;
    }

    setSkill(skill: ItemSkill | undefined): this {
        if (skill) this.item.skill = skill;
        return this;
    }
}

// Export classes for backward compatibility (even though they're empty)
// These exist for semantic distinction in code, not behavioral differences
export class SwordItem extends ToolItem { }
export class PickaxeItem extends ToolItem { }
export class AxeItem extends ToolItem { }
export class ShovelItem extends ToolItem { }

// Factory functions for cleaner call sites
export const Sword = (sprite: string) => new SwordItem(sprite);
export const Pickaxe = (sprite: string) => new PickaxeItem(sprite);
export const Axe = (sprite: string) => new AxeItem(sprite);
export const Shovel = (sprite: string) => new ShovelItem(sprite);
