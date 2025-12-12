import { ItemInventory } from "./ItemInventory";
import { ItemSprite } from "./ItemSprite";
import { ItemType } from "./ItemType";
import { ItemComponent } from "./ItemComponent";
import { ItemFunction } from "./ItemFunction";

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

/**
 * Useable item - a non-tile item that can have on_use functions and components
 * Used for tools, buckets, consumables, etc.
 */
export class UseableItem extends Item {
    private item: {
        components?: { [key: string]: ItemComponent };
        on_use?: ItemFunction[];
    };

    constructor(
        type: ItemType,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: any,
    ) {
        super(type, sprite, inventory, properties);
        this.item = {};
    }

    addComponent(key: string, value: ItemComponent) {
        this.item.components ??= {};
        this.item.components[key] = value;
        return this;
    }

    addOnUse(functions: ItemFunction[]) {
        this.item.on_use ??= [];
        this.item.on_use.push(...functions);
        return this;
    }
}
