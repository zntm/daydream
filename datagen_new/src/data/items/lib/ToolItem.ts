import { Item, ItemDurability, ItemHarvest, ItemSkill, ItemType } from "./";

export class ToolItem extends Item {
    // @ts-ignore
    protected item?: {
        damage?: number;
        harvest?: ItemHarvest;
        durability?: ItemDurability;
        skill?: ItemSkill;
    };

    constructor(sprite: string) {
        super(ItemType.Tool, sprite, "#phantasia:item/generic/inventory_tool");
    }

    setDamage(damage: number) {
        this.item ??= {};
        this.item.damage = damage;
        return this;
    }

    setItemDurability(durability: ItemDurability) {
        this.item ??= {};
        this.item.durability = durability;
        return this;
    }

    setItemHarvest(harvest: ItemHarvest) {
        this.item ??= {};
        this.item.harvest = harvest;
        return this;
    }

    setSkill(skill: ItemSkill) {
        this.item ??= {};
        this.item.skill = skill;
        return this;
    }
}

export class SwordItem extends ToolItem {
    constructor(sprite: string) {
        super(sprite);
    }
}

export class PickaxeItem extends ToolItem {
    constructor(sprite: string) {
        super(sprite);
    }
}

export class AxeItem extends ToolItem {
    constructor(sprite: string) {
        super(sprite);
    }
}

export class ShovelItem extends ToolItem {
    constructor(sprite: string) {
        super(sprite);
    }
}
