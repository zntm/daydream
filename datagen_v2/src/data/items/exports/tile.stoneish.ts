import {
    ItemParticle,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";
import { tileBlockWallItems } from "../lib/groups/";

export default [
    {
        namespace: "phantasia",
        id: "nightrock",
        harvest: new TileItemHarvest(
            0.52,
            0,
            new ItemParticle(
                "#phantasia:tile/particle_colour/nightrock",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/pickaxe"),
        ),
        sfx: "#phantasia:tile/sfx/stone",
        audioProperties: new TileItemAudioProperties(0.7, 0.6),
    },
    {
        namespace: "phantasia",
        id: "sandstone",
        harvest: new TileItemHarvest(
            0.22,
            0,
            new ItemParticle(
                "#phantasia:tile/particle_colour/sand",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/pickaxe"),
        ),
        sfx: "#phantasia:tile/sfx/stone",
        audioProperties: new TileItemAudioProperties(0.55, 0.4),
    },
    {
        namespace: "phantasia",
        id: "stone",
        harvest: new TileItemHarvest(
            0.36,
            0,
            new ItemParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/pickaxe"),
        ),
        sfx: "#phantasia:tile/sfx/stone",
        audioProperties: new TileItemAudioProperties(0.65, 0.5),
    },
    {
        namespace: "phantasia",
        id: "grimstone",
        harvest: new TileItemHarvest(
            0.52,
            0,
            new ItemParticle(
                "#352a4a",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/pickaxe"),
        ),
        sfx: "#phantasia:tile/sfx/stone",
        audioProperties: new TileItemAudioProperties(0.7, 0.6),
    },
].map(({ namespace, id, harvest, sfx, audioProperties }) => [
    tileBlockWallItems(
        namespace,
        id,
        [
            TileItemProperties.CanFlip,
            TileItemProperties.CanMirror,
            TileItemProperties.IsTile,
        ],
        harvest,
        sfx,
        audioProperties,
    ),
    tileBlockWallItems(
        namespace,
        `${id}_bricks`,
        [TileItemProperties.IsTile],
        harvest,
        sfx,
        audioProperties,
    ),
]);
