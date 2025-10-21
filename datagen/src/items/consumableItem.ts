import { DatagenReturnData } from "../../index";
import {
    Item,
    ItemSprite,
    ItemConsumable,
    ItemInventory,
    ItemType,
} from "../items";

export default (
    id: ItemType,
    inventory: string | ItemInventory,
    consumable: ItemConsumable,
) => {
    class ConsumableItem extends Item {
        private item?: {
            consumable?: ConsumableItem;
        };

        constructor(
            type: ItemType,
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
        `generated/data/items/${id}.json`,
        new ConsumableItem(
            ItemType.Default,
            `phantasia:item/${id}`,
            inventory,
        ).setItemConsumable(consumable),
    );
};
