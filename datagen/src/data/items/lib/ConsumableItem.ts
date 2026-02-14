import { Item } from "./Item";
import type { ItemComponentData } from "./ItemComponent";
import type { ItemInventory } from "./ItemInventory";
import type { ItemScript } from "./ItemScript";
import { ItemType } from "./ItemType";

export class ConsumableItemData {
    private hp: number;
    private saturation: number;
    private cooldown: any;
    private sfx: any;

    constructor(hp: number, saturation: number, cooldown: any, sfx: any) {
        this.hp = hp;
        this.saturation = saturation;
        this.cooldown = cooldown;
        this.sfx = sfx;
    }
}

export class ConsumableItem extends Item {
    protected override item?: {
        consumable?: ConsumableItemData;
        components?: { [key: string]: ItemComponentData };
        on_use?: ItemScript[];
    };

    constructor(
        sprite: string,
        inventory: string | ItemInventory,
        consumable: ConsumableItemData,
    ) {
        super(ItemType.Default, sprite, inventory);

        this.setItemConsumable(consumable);
    }

    setItemConsumable(consumable: ConsumableItemData) {
        this.item ??= {};
        this.item.consumable = consumable;

        return this;
    }
}
