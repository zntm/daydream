import { Sound } from "../../../assets/sounds/lib/Sound";
import { ConsumableItemData, ItemCooldown } from "../lib";
import { consumableCookableItems } from "../lib/groups/";

export default [
    { namespace: "phantasia", id: "beef", rawHp: 6, rawSat: 4, cookedHp: 12, cookedSat: 12 },
    { namespace: "phantasia", id: "chicken", rawHp: 4, rawSat: 2, cookedHp: 8, cookedSat: 8 },
    { namespace: "phantasia", id: "cod", rawHp: 3, rawSat: 3, cookedHp: 14, cookedSat: 6 },
    { namespace: "phantasia", id: "frog_leg", rawHp: 2, rawSat: 6, cookedHp: 10, cookedSat: 4 },
    { namespace: "phantasia", id: "mutton", rawHp: 6, rawSat: 4, cookedHp: 12, cookedSat: 12 },
    { namespace: "phantasia", id: "rabbit", rawHp: 3, rawSat: 2, cookedHp: 6, cookedSat: 4 },
    { namespace: "phantasia", id: "salmon", rawHp: 3, rawSat: 3, cookedHp: 14, cookedSat: 6 },
].map(({ namespace, id, rawHp, rawSat, cookedHp, cookedSat }) =>
    consumableCookableItems(
        namespace,
        id,
        new ConsumableItemData(
            rawHp,
            rawSat,
            new ItemCooldown("phantasia:food", 1),
            new Sound("phantasia:sfx/item/eat"),
        ),
        new ConsumableItemData(
            cookedHp,
            cookedSat,
            new ItemCooldown("phantasia:food", 1),
            new Sound("phantasia:sfx/item/eat"),
        ),
    ),
);
