import { Sound } from "../../../lib/Sound";
import { ItemConsumable } from "../lib/ItemConsumable";
import { ItemCooldown } from "../lib/ItemCooldown";
import { ConsumableItem } from "../lib/ConsumableItem";

const { default: cookableConsumableItems } = import.meta.require("./cookableConsumableItems");

export default [
    new ConsumableItem(
        "apple",
        "#phantasia:item/generic/inventory_default",
        new ItemConsumable(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new Sound("phantasia:sound.eat"),
        ),
    ),
    ...[
        {
            id: "chicken",
            rawConsumable: new ItemConsumable(
                4,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                8,
                8,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
        },
        {
            id: "rabbit",
            rawConsumable: new ItemConsumable(
                3,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                6,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
        },
    ]
        .map(({ id, rawConsumable, cookedConsumable }) =>
            cookableConsumableItems(id, rawConsumable, cookedConsumable),
        )
        .flat(),
];
