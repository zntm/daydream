import { DatagenReturnData } from "../../../../lib";
import { ConsumableItem, ConsumableItemData } from "../index";

export default (
    id: string,
    rawConsumable: ConsumableItemData,
    cookedConsumable: ConsumableItemData,
) => [
        new DatagenReturnData(
            `${id}.json`,
            new ConsumableItem(
                `phantasia:item/${id}`,
                "#phantasia:item/generic/inventory_default",
                rawConsumable,
            ),
        ),
        new DatagenReturnData(
            `cooked_${id}.json`,
            new ConsumableItem(
                `phantasia:item/cooked_${id}`,
                "#phantasia:item/generic/inventory_default",
                cookedConsumable,
            ),
        ),
    ];
