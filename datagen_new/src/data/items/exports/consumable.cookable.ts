import { ConsumableItemData, ItemCooldown, ItemSFX } from "../lib";
import { consumableCookableItems } from "../lib/groups/";

class CookableConsumableItems {
    namespace: string;
    id: string;
    rawConsumableHp: number;
    rawConsumableSaturation: number;
    cookedConsumableHp: number;
    cookedConsumableSaturation: number;

    constructor(
        namespace: string,
        id: string,
        rawConsumableHp: number,
        rawConsumableSaturation: number,
        cookedConsumableHp: number,
        cookedConsumableSaturation: number,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.rawConsumableHp = rawConsumableHp;
        this.rawConsumableSaturation = rawConsumableSaturation;
        this.cookedConsumableHp = cookedConsumableHp;
        this.cookedConsumableSaturation = cookedConsumableSaturation;
    }
}

export default [
    new CookableConsumableItems("phantasia", "chicken", 4, 2, 8, 4),
    new CookableConsumableItems("phantasia", "rabbit", 6, 4, 12, 12),
].map(
    ({
        namespace,
        id,
        rawConsumableHp,
        rawConsumableSaturation,
        cookedConsumableHp,
        cookedConsumableSaturation,
    }) =>
        consumableCookableItems(
            namespace,
            id,
            new ConsumableItemData(
                rawConsumableHp,
                rawConsumableSaturation,
                new ItemCooldown("phantasia:food", 1),
                new ItemSFX("phantasia:sfx/item/eat", 1),
            ),
            new ConsumableItemData(
                cookedConsumableHp,
                cookedConsumableSaturation,
                new ItemCooldown("phantasia:food", 1),
                new ItemSFX("phantasia:sfx/item/eat", 1),
            ),
        ),
);
