import tieredEquipmentRecipes from "../../lib/groups/tieredEquipmentRecipes";

export default [
    ...["platinum", "gold", "iron", "copper"]
        .map((id) =>
            tieredEquipmentRecipes(
                "phantasia",
                id,
                "#phantasia:tile/generic/workbench",
                "phantasia:furnace",
            ),
        )
        .flat(),
];
