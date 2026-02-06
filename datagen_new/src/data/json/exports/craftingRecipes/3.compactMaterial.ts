import { compactMaterialRecipes } from "../../craftingRecipes/lib/groups";

enum WoodCraftingIngredientAmount {
    Workbench = 4,
    Chest = 2,
    ChestFrame = 2,
    PlanksWall = 2,
}

export default [
    "phantasia:coal",
    "phantasia:copper",
    "phantasia:iron",
    "phantasia:gold",
    "phantasia:platinum",
].map((id) => compactMaterialRecipes(id, "#phantasia:tile/generic/workbench"));
