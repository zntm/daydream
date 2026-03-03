import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemCondition,
    TileItemDrop,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";
import { tileBlockWallItems } from "../lib/groups";

export default [
    ...[
        {
            id: "dirt",
            harvest: new TileItemHarvest(
                0.36,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/dirt",
            audio: new TileItemAudioProperties(0.15, 0.05),
        },
        {
            id: "lumin_moss",
            harvest: new TileItemHarvest(
                0.26,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
            audio: new TileItemAudioProperties(0.05, 0),
        },
        {
            id: "moss",
            harvest: new TileItemHarvest(
                0.26,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
            audio: new TileItemAudioProperties(0.05, 0),
        },
        {
            id: "petrilumin",
            harvest: new TileItemHarvest(
                0.36,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
            audio: new TileItemAudioProperties(0.65, 0.5),
        },
    ].flatMap(({ id, harvest, sfx, audio }) => [
        tileBlockWallItems(
            "phantasia",
            id,
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest,
            sfx,
            audio,
        ),
        tileBlockWallItems(
            "phantasia",
            `${id}_bricks`,
            [TileItemProperties.IsTile],
            harvest,
            sfx,
            audio,
        ),
    ]),
    /* grass blocks */
    ...["grass_block", "grass_block_taiga", "grass_block_swamp"].map(
        (id) =>
            new DatagenReturnData(
                `${id}.json`,
                new TileItem(
                    ItemType.Solid,
                    `phantasia:item/${id}`,
                    "#phantasia:item/generic/inventory_tile",
                    [TileItemProperties.CanMirror, TileItemProperties.IsTile],
                )
                    .setTileDrops([new TileItemDrop("phantasia:dirt")])
                    .setTileHarvest(
                        new TileItemHarvest(
                            0.36,
                            0,
                            new ItemParticle(
                                "#phantasia:tile/particle_colour/dirt",
                                "#phantasia:tile/generic/harvest_particle_frequency",
                            ),
                        ),
                    )
                    .setTileSFX("#phantasia:tile/sfx/dirt")
                    .setTileAudioProperties(
                        new TileItemAudioProperties(0.15, 0.05),
                    ),
            ),
    ),
];
