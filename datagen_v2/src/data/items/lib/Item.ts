import type { ItemComponentData } from "./ItemComponent";
import type { ItemScript } from "./ItemScript";
import { ItemInventory } from "./ItemInventory";
import { type ItemPropertiesType, TileItemProperties } from "./ItemProperties";
import { ItemType } from "./ItemType";

export class Item {
    private type: ItemType;
    private sprite: string;
    private inventory: string | ItemInventory;
    private properties?: ItemPropertiesType[];
    protected item?: {
        components?: {
            [key: string]: ItemComponentData;
        };
        on_use?: ItemScript[];
    };

    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: ItemPropertiesType[],
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

    addItemComponent(key: string, component: ItemComponentData): Item {
        this.item ??= {};
        this.item.components ??= {};

        this.item.components[key] = component;

        return this;
    }

    setItemOnUse(on_use: ItemScript[]): Item {
        this.item ??= {};
        this.item.on_use ??= [];

        this.item.on_use.push(...on_use);

        return this;
    }
}
