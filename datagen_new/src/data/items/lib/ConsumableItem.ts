import { Item } from "./Item";
import { ItemInventory } from "./ItemInventory";
import { ItemCooldown } from "./ItemCooldown";
import { ItemSFX } from "./ItemSFX";
import { ItemType } from "./ItemType";

export class ConsumableItemData {
    private hp: number;
    private saturation: number;
    private cooldown: ItemCooldown;
    private sfx: ItemSFX;

    constructor(
        hp: number,
        saturation: number,
        cooldown: ItemCooldown,
        sfx: ItemSFX,
    ) {
        this.hp = hp;
        this.saturation = saturation;
        this.cooldown = cooldown;
        this.sfx = sfx;
    }
}

export class ConsumableItem extends Item {
    // @ts-ignore - override parent item with consumable-specific fields
    protected item: {
        consumable?: ConsumableItemData;
    } = {};

    constructor(
        sprite: string,
        inventory: string | ItemInventory,
        consumable: ConsumableItemData,
    ) {
        super(ItemType.Default, sprite, inventory);
        this.item.consumable = consumable;
    }

    setItemConsumable(consumable: ConsumableItemData): this {
        this.item.consumable = consumable;
        return this;
    }
}
