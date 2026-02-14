import { Item } from "./Item";
import { ItemSprite } from "./ItemSprite";
import { ItemConsumable } from "./ItemConsumable";
import { ItemInventory } from "./ItemInventory";
import { ItemType } from "./ItemType";

export class ConsumableItem extends Item {
    private item?: {
        consumable?: ItemConsumable;
    };

    constructor(
        id: string,
        inventory: string | ItemInventory,
        consumable: ItemConsumable,
    ) {
        super(ItemType.Default, `phantasia:item/${id}`, inventory);
        
        this.setItemConsumable(consumable);
    }

    setItemConsumable(consumable: ItemConsumable) {
        this.item ??= {};
        this.item.consumable = consumable;

        return this;
    }
}
