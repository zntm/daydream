import { DatagenReturnData } from "../../../lib";
import { Item, ItemType } from "../lib";

export default [
    new DatagenReturnData(
        "feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    new DatagenReturnData(
        "snowball.json",
        new Item(
            ItemType.Default,
            "phantasia:item/snowball",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
];
