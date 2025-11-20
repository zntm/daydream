import {
    ItemTileCondition,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileProperties,
    ItemTileSFX,
} from "./tileItem";

const { default: blockWallItems } = import.meta.require("./blockWallItems");

export default [
    ...[
        {
            id: "dirt",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/dirt",
        },
        {
            id: "lumin_moss",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.26,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
        },
        {
            id: "moss",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.26,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
        },
        {
            id: "sandstone",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.22,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/sand",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
        {
            id: "stone",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
        {
            id: "nightrock",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.52,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/nightrock",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
    ]
        .map(({ id, properties, harvest, sfx }) =>
            blockWallItems(id, properties, harvest, sfx),
        )
        .flat(),
];
