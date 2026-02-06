import { blockWallRecipes } from "../../craftingRecipes/lib/groups";

export default [
    "phantasia:moss",
    "phantasia:auburn_moss",
    "phantasia:lumin_moss",
].map((id) => blockWallRecipes(id, "#phantasia:tile/generic/workbench"));
