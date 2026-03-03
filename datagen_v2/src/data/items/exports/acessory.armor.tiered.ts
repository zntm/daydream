import tieredRegistries from "../registries/tiered";
import accessoryArmorSet from "../lib/groups/accessory.armorSet";

export default tieredRegistries.flatMap(
    ({ namespace, id, helmet, breastplate, leggings }) =>
        accessoryArmorSet(namespace, id, helmet, breastplate, leggings),
);
