import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import type { ItemHarvest } from "../lib/ItemHarvest";
import { AccessoryItem, ItemAccessoryType } from "../lib/AccessoryItem";
import { ToolItem } from "../lib/ToolItem";

export default (
    id: string,
    helmet: any,
    breastplate: any,
    leggings: any,
    sword: any,
    pickaxe: any,
    axe: any,
    shovel: any,
    harvest: any,
) => [
        new DatagenReturnData(
            `generated/data/items/${id}_helmet.json`,
            new AccessoryItem(
                `${id}_helmet`,
                ItemAccessoryType.Helmet,
                helmet.defense,
                helmet.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_breastplate.json`,
            new AccessoryItem(
                `${id}_breastplate`,
                ItemAccessoryType.Breastplate,
                breastplate.defense,
                breastplate.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_leggings.json`,
            new AccessoryItem(
                `${id}_leggings`,
                ItemAccessoryType.Leggings,
                leggings.defense,
                leggings.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_sword.json`,
            new ToolItem(
                `${id}_sword`,
                sword.durability,
                "#phantasia:item/generic/inventory_tool",
                sword.damage,
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_pickaxe.json`,
            new ToolItem(
                `${id}_pickaxe`,
                pickaxe.durability,
                "#phantasia:item/generic/inventory_tool",
                pickaxe.damage,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_axe.json`,
            new ToolItem(
                `${id}_axe`,
                axe.durability,
                "#phantasia:item/generic/inventory_tool",
                axe.damage,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `generated/data/items/${id}_shovel.json`,
            new ToolItem(
                `${id}_shovel`,
                shovel.durability,
                "#phantasia:item/generic/inventory_tool",
                shovel.damage,
                harvest.hardness,
                harvest.level,
            ),
        ),
    ];
