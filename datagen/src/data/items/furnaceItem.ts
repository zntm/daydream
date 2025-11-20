import tileItem, {
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
} from "./tileItem";
import { ItemType } from "./lib/ItemType";

export default [
    tileItem(
        "furnace",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        undefined,
        [
            new ItemTileDrop("phantasia:item/furnace").setCondition(
                new ItemTileCondition("#phantasia:item/type/pickaxe", 1),
            ),
        ],
        new ItemTileHarvest(
            0.36,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        undefined,
        "#phantasia:tile/sfx/stone",
    ),
];
