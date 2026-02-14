import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { Sound } from "../../../lib/Sound";
import { ItemConsumable } from "../lib/ItemConsumable";
import { ItemCooldown } from "../lib/ItemCooldown";
import { ConsumableItem } from "../lib/ConsumableItem";

const { default: cookableConsumableItems } = import.meta.require(
    "./cookableConsumableItems",
);

export default [
    new DatagenReturnData(
        "generated/data/items/apple.json",
        new ConsumableItem(
            "apple",
            "#phantasia:item/generic/inventory_default",
            new ItemConsumable(
                8,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        ),
    ),
    new DatagenReturnData(
        "generated/data/items/rotten_flesh.json",
        new ConsumableItem(
            "rotten_flesh",
            "#phantasia:item/generic/inventory_default",
            new ItemConsumable(
                2,
                1,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        ),
    ),
    [
        {
            id: "chicken",
            rawConsumable: new ItemConsumable(
                4,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
            cookedConsumable: new ItemConsumable(
                8,
                8,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        },
        {
            id: "rabbit",
            rawConsumable: new ItemConsumable(
                3,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
            cookedConsumable: new ItemConsumable(
                6,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sfx/item/eat"),
            ),
        },
    ].map(({ id, rawConsumable, cookedConsumable }) =>
        cookableConsumableItems(id, rawConsumable, cookedConsumable),
    ),
];
