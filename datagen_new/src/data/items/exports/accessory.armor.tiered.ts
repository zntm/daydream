import { accessoryArmorItems } from "../lib/groups";
import { tierRegistries } from "../registries";

export default tierRegistries.map(
    ({ namespace, id, armor }) =>
        accessoryArmorItems(
            namespace,
            id,
            armor
        ),
);
