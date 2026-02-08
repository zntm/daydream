import type { ItemComponentData } from "./ItemComponent";
import { ItemInventory } from "./ItemInventory";
import { type ItemPropertiesType, TileItemProperties } from "./ItemProperties";
import type { ItemScript } from "./ItemScript";
import { ItemType } from "./ItemType";

/**
 * Base Item class - the foundation for all game items.
 */
export class Item {
    private type: ItemType;
    private sprite: string;
    private inventory: string | ItemInventory;
    private properties?: ItemPropertiesType[];
    protected item?: {
        components?: Record<string, ItemComponentData>;
        on_use?: ItemScript[];
    };

    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: ItemPropertiesType[],
    ) {
        this.type = type;
        this.sprite = sprite.includes(":") ? sprite : `phantasia:item/${sprite}`;
        this.inventory = inventory;

        if (properties?.length) {
            this.properties = [...properties].sort();
        }
    }

    addItemComponent(key: string, component: ItemComponentData): this {
        this.item ??= {};
        this.item.components ??= {};
        this.item.components[key] = component;
        return this;
    }

    setItemOnUse(scripts: ItemScript[]): this {
        this.item ??= {};
        this.item.on_use = [...(this.item.on_use ?? []), ...scripts];
        return this;
    }
}
