import { Item } from "./Item";
import { ItemDurability } from "./ItemDurability";
import { ItemHarvest } from "./ItemHarvest";
import { ItemType } from "./ItemType";

export class ToolItem extends Item {
    // @ts-ignore
    private item?: {
        damage?: number;
        harvest?: ItemHarvest;
        durability?: ItemDurability;
    };

    constructor(
        sprite: string,
        damage: number,
        durability: number,
        harvestHardness: number,
        harvestLevel: number = 0,
    ) {
        super(ItemType.Tool, sprite, "#phantasia:item/generic/inventory_tool");

        this.item = {
            damage,
            durability: new ItemDurability(
                durability,
                "#phantasia:item/generic/durability_bar",
            ),
            harvest: new ItemHarvest(harvestHardness, harvestLevel),
        };
    }
}
