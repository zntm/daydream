import { ToolItem, LauncherItem } from "../lib";
import { DatagenReturnData } from "../../../lib";
import tieredRegistries from "../registries/tiered";

export default tieredRegistries.flatMap(
    ({ id, sword, pickaxe, axe, shovel, bow, harvest }) => [
        new DatagenReturnData(
            `${id}_sword.json`,
            new ToolItem(
                `phantasia:item/${id}_sword`,
                sword.damage,
                sword.durability,
                0,
                0,
            ),
        ),
        new DatagenReturnData(
            `${id}_pickaxe.json`,
            new ToolItem(
                `phantasia:item/${id}_pickaxe`,
                pickaxe.damage,
                pickaxe.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `${id}_axe.json`,
            new ToolItem(
                `phantasia:item/${id}_axe`,
                axe.damage,
                axe.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `${id}_shovel.json`,
            new ToolItem(
                `phantasia:item/${id}_shovel`,
                shovel.damage,
                shovel.durability,
                harvest.hardness,
                harvest.level,
            ),
        ),
        new DatagenReturnData(
            `${id}_bow.json`,
            new LauncherItem(
                `phantasia:item/${id}_bow`,
                bow.damage,
                bow.durability,
            ),
        ),
    ],
);
