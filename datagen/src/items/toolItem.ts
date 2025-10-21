import { DatagenReturnData } from "../../index";
import {
    Item,
    ItemInventory,
    ItemDurability,
    ItemType,
    ItemHarvest,
} from "../items";

export default (
    id: ItemType,
    durabilityAmount: number,
    durabilityBar: string,
    damage?: number,
    harvestHardness?: number,
    harvestLevel?: number,
) => {
    class ToolItem extends Item {
        private item?: {
            damage?: number;
            harvest?: ItemHarvest;
            durability?: ItemDurability;
        };

        constructor(
            type: ItemType,
            sprite: string,
            inventory: string | ItemInventory,
        ) {
            super(type, sprite, inventory);
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

    const tool = new ToolItem(
        ItemType.Tool,
        `phantasia:item/${id}`,
        "#phantasia:item/generic/inventory_tool",
    ).setItemDurability(new ItemDurability(durabilityAmount, durabilityBar));

    if (damage) {
        tool.setItemDamage(damage);
    }

    if (harvestHardness) {
        tool.setItemHarvest(new ItemHarvest(harvestHardness, harvestLevel));
    }

    return new DatagenReturnData(`generated/data/items/${id}.json`, tool);
};
