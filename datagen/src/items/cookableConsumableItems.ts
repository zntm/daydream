import type { ItemConsumable, ItemInventory } from "../items";

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
