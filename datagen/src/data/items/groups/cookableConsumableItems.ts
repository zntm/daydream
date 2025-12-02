import type { ItemConsumable } from "../lib/ItemConsumable";
import { ConsumableItem } from "../lib/ConsumableItem";

export default (
    id: string,
    rawConsumable: ItemConsumable,
    cookedConsumable: ItemConsumable,
) => [
        new ConsumableItem(
            `cooked_${id}`,
            "#phantasia:item/generic/inventory_default",
            cookedConsumable,
        ),
        new ConsumableItem(
            `raw_${id}`,
            "#phantasia:item/generic/inventory_default",
            rawConsumable,
        ),
    ];
