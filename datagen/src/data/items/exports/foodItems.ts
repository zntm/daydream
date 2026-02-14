import { DatagenReturnData, Sound } from "../../../lib";
import { ConsumableItem, ConsumableItemData, ItemCooldown } from "../lib";
import cookableConsumableItems from "../lib/groups/consumable.cookable";

export default [
    new DatagenReturnData(
        "apple.json",
        new ConsumableItem(
            "phantasia:item/apple",
            "#phantasia:item/generic/inventory_default",
            new ConsumableItemData(
                8,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        ),
    ),
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
    ...[
        {
            id: "chicken",
            rawConsumable: new ConsumableItemData(
                4,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
            cookedConsumable: new ConsumableItemData(
                8,
                8,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        },
        {
            id: "rabbit",
            rawConsumable: new ConsumableItemData(
                3,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
            cookedConsumable: new ConsumableItemData(
                6,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        },
    ].flatMap(({ id, rawConsumable, cookedConsumable }) =>
        cookableConsumableItems(id, rawConsumable, cookedConsumable),
    ),
];
