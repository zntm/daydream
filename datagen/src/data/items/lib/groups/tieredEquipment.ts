import { DatagenReturnData } from "../../../../lib";
import { AccessoryItem, ItemAccessoryType, ToolItem } from "../index";

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
            `${id}_helmet.json`,
            new AccessoryItem(
                `${id}_helmet`,
                ItemAccessoryType.Helmet,
                helmet.defense,
                helmet.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `${id}_breastplate.json`,
            new AccessoryItem(
                `${id}_breastplate`,
                ItemAccessoryType.Breastplate,
                breastplate.defense,
                breastplate.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `${id}_leggings.json`,
            new AccessoryItem(
                `${id}_leggings`,
                ItemAccessoryType.Leggings,
                leggings.defense,
                leggings.durability,
                "#phantasia:item/generic/inventory_armor",
            ),
        ),
        new DatagenReturnData(
            `${id}_sword.json`,
            new ToolItem(
                `${id}_sword`,
                sword.damage,
                sword.durability,
                0, // harvestHardness (swords don't usually mine)
                0, // harvestLevel
            ),
        ),
        new DatagenReturnData(
            `${id}_pickaxe.json`,
            new ToolItem(
                `${id}_pickaxe`,
                pickaxe.damage,
                pickaxe.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `${id}_axe.json`,
            new ToolItem(
                `${id}_axe`,
                axe.damage,
                axe.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `${id}_shovel.json`,
            new ToolItem(
                `${id}_shovel`,
                shovel.damage,
                shovel.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
    ];
