import type { ItemConsumable } from "../lib/ItemConsumable";
import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ConsumableItem } from "../lib/ConsumableItem";

export default (
    id: string,
    rawConsumable: ItemConsumable,
    cookedConsumable: ItemConsumable,
) => [
    new DatagenReturnData(
        `generated/data/items/cooked_${id}.json`,
        new ConsumableItem(
            `cooked_${id}`,
            "#phantasia:item/generic/inventory_default",
            cookedConsumable,
        ),
    ),
    new DatagenReturnData(
        `generated/data/items/raw_${id}.json`,
        new ConsumableItem(
            `raw_${id}`,
            "#phantasia:item/generic/inventory_default",
            rawConsumable,
        ),
    ),
];
