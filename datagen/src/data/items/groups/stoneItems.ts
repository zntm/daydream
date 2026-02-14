import {
    TileItemCondition,
    TileItemHarvest,
    TileItemParticle,
    TileItemProperties,
} from "../lib/TileItem";

const { default: blockWallItems } = import.meta.require("./blockWallItems");

export default [
    ...[
        {
            id: "dirt",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.36,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/dirt",
            lowpass: 0.15,
            reverb: 0.05,
        },
        {
            id: "lumin_moss",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.26,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
            lowpass: 0.05,
            reverb: 0.0,
        },
        {
            id: "moss",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.26,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/foliage",
            lowpass: 0.05,
            reverb: 0.0,
        },
        {
            id: "sandstone",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.22,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/sand",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
            lowpass: 0.55,
            reverb: 0.4,
        },
        {
            id: "stone",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.36,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
            lowpass: 0.65,
            reverb: 0.5,
        },
        {
            id: "nightrock",
            properties: [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
            harvest: new TileItemHarvest(
                0.52,
                0,
                new TileItemParticle(
                    "#phantasia:tile/particle_colour/nightrock",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
            lowpass: 0.7,
            reverb: 0.6,
        },
    ]
        .map(({ id, properties, harvest, sfx, lowpass, reverb }) =>
            blockWallItems(id, properties, harvest, sfx, lowpass, reverb),
        )
        .flat(),
];
