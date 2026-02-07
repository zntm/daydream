import { ConsumableItem, type ConsumableItemData } from "../";
import { DatagenReturnData } from "../../../../lib";

export default (
    namespace: string,
    id: string,
    rawConsumableItemData: ConsumableItemData,
    cookedConsumableItemData: ConsumableItemData,
) => [
    new DatagenReturnData(
        `cooked_${id}.json`,
        new ConsumableItem(
            `${namespace}:item/cooked_${id}`,
            "#phantasia:item/generic/inventory_default",
            cookedConsumableItemData,
        ),
    ),
    new DatagenReturnData(
        `raw_${id}.json`,
        new ConsumableItem(
            `${namespace}:item/raw_${id}`,
            "#phantasia:item/generic/inventory_default",
            rawConsumableItemData,
        ),
    ),
];
