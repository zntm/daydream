import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Item } from "./lib/Item";
import { ItemType } from "./lib/ItemType";

export default [
    new DatagenReturnData(
        "generated/data/items/feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
];
