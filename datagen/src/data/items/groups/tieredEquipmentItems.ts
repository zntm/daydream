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
        new AccessoryItem(
            `${id}_helmet`,
            ItemAccessoryType.Helmet,
            helmet.defense,
            helmet.durability,
            "#phantasia:item/generic/inventory_armor",
        ),
        new AccessoryItem(
            `${id}_breastplate`,
            ItemAccessoryType.Breastplate,
            breastplate.defense,
            breastplate.durability,
            "#phantasia:item/generic/inventory_armor",
        ),
        new AccessoryItem(
            `${id}_leggings`,
            ItemAccessoryType.Leggings,
            leggings.defense,
            leggings.durability,
            "#phantasia:item/generic/inventory_armor",
        ),
        new ToolItem(
            `${id}_sword`,
            sword.durability,
            "#phantasia:item/generic/inventory_tool",
            sword.damage,
        ),
        new ToolItem(
            `${id}_pickaxe`,
            pickaxe.durability,
            "#phantasia:item/generic/inventory_tool",
            pickaxe.damage,
            harvest.hardness,
            harvest.level,
        ),
        new ToolItem(
            `${id}_axe`,
            axe.durability,
            "#phantasia:item/generic/inventory_tool",
            axe.damage,
            harvest.hardness,
            harvest.level,
        ),
        new ToolItem(
            `${id}_shovel`,
            shovel.durability,
            "#phantasia:item/generic/inventory_tool",
            shovel.damage,
            harvest.hardness,
            harvest.level,
        ),
    ];
