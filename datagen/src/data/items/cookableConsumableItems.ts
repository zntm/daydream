import type { ItemConsumable } from "./lib/ItemConsumable";
import type { ItemInventory } from "./lib/ItemInventory";

const { default: consumableItem } = import.meta.require("./consumableItem");

export default (
    id: string,
    rawConsumable: ItemConsumable,
    cookedConsumable: ItemConsumable,
) => [
        consumableItem(
            `cooked_${id}`,
            "#phantasia:item/generic/inventory_default",
            cookedConsumable,
        ),
        consumableItem(
            `raw_${id}`,
            "#phantasia:item/generic/inventory_default",
            rawConsumable,
        ),
    ];
