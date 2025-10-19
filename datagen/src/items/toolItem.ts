import { DatagenReturnData } from "../../index";
import { Item, ItemSprite, ItemInventory, ItemDurability } from "../items";

export class ToolItem extends Item {
    constructor(
        type: string,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
    ) {
        super(type, sprite, inventory);
    }

    setItemDurability(durability: ItemDurability) {
        this.item ??= {};
        this.item.durability = durability;

        return this;
    }
}

export default (
    id: string,
    sprite: string | ItemSprite,
    durabilityAmount: number,
    durabilityBar: string,
) =>
    new DatagenReturnData(
        `generated/items/${id}.json`,
        new ToolItem(
            "default",
            sprite,
            "#phantasia:item/generic/inventory_tool",
        ).setItemDurability(
            new ItemDurability(durabilityAmount, durabilityBar),
        ),
    );
