import { DatagenReturnData } from "../../../lib";
import { ToolItem } from "../lib";
import { woodRegistries } from "../registries";

export default woodRegistries.map(({ id }) => [
    new DatagenReturnData(
        `${id}_pickaxe.json`,
        new ToolItem(`${id}_pickaxe`, 1, 73, 1, 1),
    ),
    new DatagenReturnData(
        `${id}_shovel.json`,
        new ToolItem(`${id}_shovel`, 1, 65, 1, 1),
    ),
]);
