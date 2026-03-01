import { Sound } from "../../../assets/sounds/lib/Sound";
import { DatagenReturnData } from "../../../lib";
import { ConsumableItem, ConsumableItemData, ItemCooldown } from "../lib";

export default [
    new DatagenReturnData(
        "rotten_flesh.json",
        new ConsumableItem(
            "phantasia:item/rotten_flesh",
            "#phantasia:item/generic/inventory_default",
            new ConsumableItemData(
                2,
                1,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        ),
    ),
];
