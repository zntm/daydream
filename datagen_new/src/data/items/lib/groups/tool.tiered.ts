import { DatagenReturnData } from "../../../../lib";
import {
    AxeItem,
    ItemDurability,
    ItemHarvest,
    PickaxeItem,
    ShovelItem,
    SwordItem,
    ItemSkill,
} from "../";

export default (
    namespace: string,
    id: string,
    tools: {
        sword: { damage: number; durability: number; skill?: ItemSkill };
        pickaxe: { damage: number; durability: number; skill?: ItemSkill };
        axe: { damage: number; durability: number; skill?: ItemSkill };
        shovel: { damage: number; durability: number; skill?: ItemSkill };
    },
    harvest: { hardness: number; level: number },
) => [
        new DatagenReturnData(
            `${id}_sword.json`,
            new SwordItem(`${namespace}:item/${id}_sword`)
                .setDamage(tools.sword.damage)
                .setItemDurability(
                    new ItemDurability(
                        tools.sword.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                )
                .setSkill(tools.sword.skill!),
        ),
        new DatagenReturnData(
            `${id}_pickaxe.json`,
            new PickaxeItem(`${namespace}:item/${id}_pickaxe`)
                .setDamage(tools.pickaxe.damage)
                .setItemDurability(
                    new ItemDurability(
                        tools.pickaxe.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                )
                .setItemHarvest(new ItemHarvest(harvest.hardness, harvest.level))
                .setSkill(tools.pickaxe.skill!),
        ),
        new DatagenReturnData(
            `${id}_axe.json`,
            new AxeItem(`${namespace}:item/${id}_axe`)
                .setDamage(tools.axe.damage)
                .setItemDurability(
                    new ItemDurability(
                        tools.axe.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                )
                .setItemHarvest(new ItemHarvest(harvest.hardness, harvest.level))
                .setSkill(tools.axe.skill!),
        ),
        new DatagenReturnData(
            `${id}_shovel.json`,
            new ShovelItem(`${namespace}:item/${id}_shovel`)
                .setDamage(tools.shovel.damage)
                .setItemDurability(
                    new ItemDurability(
                        tools.shovel.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                )
                .setItemHarvest(new ItemHarvest(harvest.hardness, harvest.level))
                .setSkill(tools.shovel.skill!),
        ),
    ];
