import { DatagenReturnData } from "../../index";
import { Item, ItemSprite, ItemConsumable, ItemInventory } from "../items";

export default (
    id: string,
    sprite: string | ItemSprite,
    inventory: string | ItemInventory,
    consumable: ItemConsumable,
) => {
    class ConsumableItem extends Item {
        constructor(
            type: string,
            sprite: string | ItemSprite,
            inventory: string | ItemInventory,
        ) {
            super(type, sprite, inventory);
        }

        setItemConsumable(consumable: any) {
            this.item ??= {};
            this.item.consumable = consumable;

            return this;
        }
    }

    return new DatagenReturnData(
        `generated/items/${id}.json`,
        new ConsumableItem("default", sprite, inventory).setItemConsumable(
            consumable,
        ),
    );
};
