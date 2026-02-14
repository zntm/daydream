import woodRecipes from "../../lib/groups/woodRecipes";

export default [
    ...["birch", "oak", "mangrove", "pine"]
        .map((id) =>
            woodRecipes(
                "phantasia",
                id,
                "phantasia:iron",
                "#phantasia:tile/generic/workbench",
            ),
        )
        .flat(),
];
