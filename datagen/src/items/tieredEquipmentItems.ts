import type { ItemHarvest } from "../items";

const { default: accessoryItem, ItemAccessoryType } = import.meta.require(
    "./accessoryItem",
);
const { default: toolItem } = import.meta.require("./toolItem");
/*
id: string,
armorType: ItemAccessoryType,
armorDefense: number,
durabilityAmount: number,
durabilityBar: string,*/
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
    accessoryItem(
        `${id}_helmet`,
        ItemAccessoryType.Helmet,
        helmet.defense,
        helmet.durability,
        "#phantasia:item/generic/inventory_armor",
    ),
    accessoryItem(
        `${id}_breastplate`,
        ItemAccessoryType.Breastplate,
        breastplate.defense,
        breastplate.durability,
        "#phantasia:item/generic/inventory_armor",
    ),
    accessoryItem(
        `${id}_leggings`,
        ItemAccessoryType.Leggings,
        leggings.defense,
        leggings.durability,
        "#phantasia:item/generic/inventory_armor",
    ),
    toolItem(
        `${id}_sword`,
        sword.durability,
        "#phantasia:item/generic/inventory_tool",
        sword.damage,
    ),
    toolItem(
        `${id}_pickaxe`,
        pickaxe.durability,
        "#phantasia:item/generic/inventory_tool",
        pickaxe.damage,
        harvest.hardness,
        harvest.level,
    ),
    toolItem(
        `${id}_axe`,
        axe.durability,
        "#phantasia:item/generic/inventory_tool",
        axe.damage,
        harvest.hardness,
        harvest.level,
    ),
    toolItem(
        `${id}_shovel`,
        shovel.durability,
        "#phantasia:item/generic/inventory_tool",
        shovel.damage,
        harvest.hardness,
        harvest.level,
    ),
];
