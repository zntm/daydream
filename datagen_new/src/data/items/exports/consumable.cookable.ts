import { Sound } from "../../../assets/sounds/lib/Sound";
import { ConsumableItemData, ItemCooldown } from "../lib";
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
    new CookableConsumableItems("phantasia", "beef", 6, 4, 12, 12),
    new CookableConsumableItems("phantasia", "chicken", 4, 2, 8, 4),
    new CookableConsumableItems("phantasia", "cod", 3, 3, 14, 6),
    new CookableConsumableItems("phantasia", "frog_leg", 2, 6, 10, 4),
    new CookableConsumableItems("phantasia", "mutton", 6, 4, 12, 12),
    new CookableConsumableItems("phantasia", "salmon", 3, 3, 14, 6),
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
                new Sound("phantasia:sfx/item/eat"),
            ),
            new ConsumableItemData(
                cookedConsumableHp,
                cookedConsumableSaturation,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        ),
);
