import { DatagenReturnData } from "../../../lib";
import { ItemDurability, ToolItem } from "../lib";
import { woodRegistries } from "../registries";

export default woodRegistries.map(({ namespace, id }) => [
    new DatagenReturnData(
        `${id}_pickaxe.json`,
        new ToolItem(`phantasia:item/${id}_pickaxe`)
            .setItemDurability(new ItemDurability(73, "#phantasia:item/generic/durability_bar")),
    ),
    new DatagenReturnData(
        `${id}_shovel.json`,
        new ToolItem(`phantasia:item/${id}_shovel`)
            .setItemDurability(new ItemDurability(65, "#phantasia:item/generic/durability_bar")),
    ),
]);
