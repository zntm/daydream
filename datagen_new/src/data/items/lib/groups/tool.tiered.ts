import { DatagenReturnData } from "../../../../lib";
import {
    ItemDurability,
    ItemHarvest,
    ItemSkill,
    Sword,
    Pickaxe,
    Axe,
    Shovel,
} from "../";

interface ToolData {
    damage: number;
    durability: number;
    skill?: ItemSkill;
}

interface HarvestData {
    hardness: number;
    level: number;
}

interface ToolsConfig {
    sword: ToolData;
    pickaxe: ToolData;
    axe: ToolData;
    shovel: ToolData;
}

const DURABILITY_BAR = "#phantasia:item/generic/durability_bar";

const makeTool = (
    factory: (sprite: string) => ReturnType<typeof Sword>,
    namespace: string,
    id: string,
    toolType: string,
    data: ToolData,
    harvest?: HarvestData,
) => {
    const tool = factory(`${namespace}:item/${id}_${toolType}`)
        .setDamage(data.damage)
        .setItemDurability(new ItemDurability(data.durability, DURABILITY_BAR))
        .setSkill(data.skill);

    if (harvest) {
        tool.setItemHarvest(new ItemHarvest(harvest.hardness, harvest.level));
    }

    return new DatagenReturnData(`${id}_${toolType}.json`, tool);
};

export default (
    namespace: string,
    id: string,
    tools: ToolsConfig,
    harvest: HarvestData,
) => [
    makeTool(Sword, namespace, id, "sword", tools.sword),
    makeTool(Pickaxe, namespace, id, "pickaxe", tools.pickaxe, harvest),
    makeTool(Axe, namespace, id, "axe", tools.axe, harvest),
    makeTool(Shovel, namespace, id, "shovel", tools.shovel, harvest),
];
