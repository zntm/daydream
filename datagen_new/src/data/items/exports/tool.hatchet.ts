import { DatagenReturnData } from "../../../lib";
import { ToolItem, ItemDurability, ItemHarvest } from "../lib";

export default new DatagenReturnData(
    "hatchet.json",
    new ToolItem("phantasia:item/hatchet")
        .setDamage(2)
        .setItemDurability(
            new ItemDurability(68, "#phantasia:item/generic/durability_bar"),
        )
        .setItemHarvest(new ItemHarvest(1, 1)),
);
