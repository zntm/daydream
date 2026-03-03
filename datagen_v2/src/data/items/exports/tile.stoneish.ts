import {
    ItemParticle,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";
import { tileBlockWallItems } from "../lib/groups/";

class StoneishItems {
    namespace: string;
    id: string;
    harvest: TileItemHarvest;
    sfx: string;
    audioProperties: TileItemAudioProperties;

    constructor(
        namespace: string,
        id: string,
        harvest: TileItemHarvest,
        sfx: string,
        audioProperties: TileItemAudioProperties,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.harvest = harvest;
        this.sfx = sfx;
        this.audioProperties = audioProperties;
    }
}

export default [
    new StoneishItems(
        "phantasia",
        "nightrock",
        new TileItemHarvest(
            0.52,
            2,
            new ItemParticle(
                "#phantasia:tile/particle_colour/nightrock",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new TileItemCondition("#phantasia:item/type/pickaxe"),
        ),
        "#phantasia:tile/sfx/stone",
        new TileItemAudioProperties(0.7, 0.6),
    ),
    new StoneishItems(
        "phantasia",
        "sandstone",
        new TileItemHarvest(
            0.22,
            2,
            new ItemParticle(
                "#phantasia:tile/particle_colour/sand",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/stone",
        new TileItemAudioProperties(0.55, 0.4),
    ),
    new StoneishItems(
        "phantasia",
        "stone",
        new TileItemHarvest(
            0.36,
            2,
            new ItemParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        "#phantasia:tile/sfx/stone",
        new TileItemAudioProperties(0.65, 0.5),
    ),
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
