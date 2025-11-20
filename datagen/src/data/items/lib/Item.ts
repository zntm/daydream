import { ItemInventory } from "./ItemInventory";
import { ItemSprite } from "./ItemSprite";
import { ItemType } from "./ItemType";

export class Item {
    private type: ItemType;
    private sprite: string | ItemSprite;
    private inventory: string | ItemInventory;
    private properties?: any;

    constructor(
        type: ItemType,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: any,
    ) {
        this.type = type;
        this.sprite = sprite;
        this.inventory = inventory;

        if (properties !== undefined) {
            this.properties = Array.isArray(properties)
                ? properties.toSorted()
                : [properties];
        }
    }
}
