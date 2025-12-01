import { SmartValueIntRandom } from "../../lib/SmartValue";
import { ItemType } from "./lib/ItemType";
import tileItem, {
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTileProperties,
    ItemTileSFX,
} from "./tileItem";

export default [
    tileItem(
        "twig",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror],
        [new ItemTileDrop("phantasia:twig")],
        new ItemTileHarvest(
            0.11,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setIndex(
            new SmartValueIntRandom(1, 3),
        ),
        "#phantasia:tile/sfx/wood",
    ),
    tileItem(
        "rock",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror],
        [new ItemTileDrop("phantasia:rock")],
        new ItemTileHarvest(
            0.11,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setIndex(
            new SmartValueIntRandom(1, 4),
        ),
        "#phantasia:tile/sfx/stone",
    ),
];
