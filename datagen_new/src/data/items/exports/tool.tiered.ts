import { toolTieredItems } from "../lib/groups";
import { tierRegistries } from "../registries";

export default tierRegistries.map(({ namespace, id, tools, harvest }) =>
    toolTieredItems(namespace, id, tools, harvest),
);
