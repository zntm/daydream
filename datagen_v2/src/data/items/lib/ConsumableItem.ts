import { ItemInventory } from "./ItemInventory";
import { ItemType } from "./ItemType";

const { Item } = import.meta.require("./Item");

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
    private item?: {
        consumable?: ConsumableItemData;
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
