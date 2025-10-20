import { DatagenReturnData } from "../../index";
import {
    Item,
    ItemInventory,
    ItemDurability,
    ItemType,
    ItemHarvest,
} from "../items";

export default (
    id: string,
    harvestHardness: number,
    harvestLevel: number,
    durabilityAmount: number,
    durabilityBar: string,
) => {
    class ToolItem extends Item {
        private item?: {
            harvest?: ItemHarvest;
            durability?: ItemDurability;
        };

        constructor(
            type: string,
            sprite: string,
            inventory: string | ItemInventory,
        ) {
            super(type, sprite, inventory);
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

    return new DatagenReturnData(
        `generated/data/items/${id}.json`,
        new ToolItem(
            ItemType.Tool,
            `phantasia:item/${id}`,
            "#phantasia:item/generic/inventory_tool",
        )
            .setItemDurability(
                new ItemDurability(durabilityAmount, durabilityBar),
            )
            .setItemHarvest(new ItemHarvest(harvestHardness, harvestLevel)),
    );
};
