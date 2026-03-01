import { Sound } from "../../../assets/sounds/lib/Sound";
import { DatagenReturnData } from "../../../lib";
import { ConsumableItem, ConsumableItemData, ItemCooldown } from "../lib";

class FruitConsumableItem {
    namespace: string;
    id: string;
    consumableItemData: ConsumableItemData;

    constructor(
        namespace: string,
        id: string,
        consumableItemData: ConsumableItemData,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.consumableItemData = consumableItemData;
    }
}

export default [
    new FruitConsumableItem(
        "phantasia",
        "lumin_vine_berry",
        new ConsumableItemData(
            6,
            2,
            new ItemCooldown("phantasia:food", 0.5),
            new Sound("phantasia:sfx/item/eat"),
        ),
    ),
    new FruitConsumableItem(
        "phantasia",
        "apple",
        new ConsumableItemData(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new Sound("phantasia:sfx/item/eat"),
        ),
    ),
].map(
    ({ namespace, id, consumableItemData }) =>
        new DatagenReturnData(
            `${id}.json`,
            new ConsumableItem(
                `${namespace}:item/${id}`,
                "#phantasia:item/generic/inventory_default",
                consumableItemData,
            ),
        ),
);
