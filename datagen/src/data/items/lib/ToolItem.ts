import { Item } from "./Item";
import { ItemInventory } from "./ItemInventory";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";
import { ItemHarvest } from "./ItemHarvest";

export class ToolItem extends Item {
    private item?: {
        damage?: number;
        harvest?: ItemHarvest;
        durability?: ItemDurability;
    };

    constructor(
        id: string,
        durabilityAmount: number,
        durabilityBar: string,
        damage?: number,
        harvestHardness?: number,
        harvestLevel?: number,
    ) {
        super(ItemType.Tool, `phantasia:item/${id}`, "#phantasia:item/generic/inventory_tool");

        this.setItemDurability(new ItemDurability(durabilityAmount, durabilityBar));

        if (damage) {
            this.setItemDamage(damage);
        }

        if (harvestHardness) {
            this.setItemHarvest(new ItemHarvest(harvestHardness, harvestLevel));
        }
    }

    setItemDamage(damage: number) {
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
}
