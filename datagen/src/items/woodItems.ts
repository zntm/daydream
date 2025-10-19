import { Item, ItemSprite, ItemInventory, ItemDurability } from "../items";
import tileItem, {
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileSFX,
} from "./tileItem";

export default (
    id: string,
    logSprite: string | ItemSprite,
    logParticleId: string | string[],
    plankParticleId: string | string[],
) => [
    tileItem(
        id,
        "untouchable",
        logSprite,
        "#phantasia:item/generic/inventory_tile",
        [new ItemTileDrop(`phantasia:${id}`)],
        new ItemTileHarvest(
            0.56,
            1,
            new ItemTileParticle(
                logParticleId,
                "#phantasia:tile/generic/harvest_particle_colour",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
];
