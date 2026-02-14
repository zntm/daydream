import {
    ItemParticle,
    TileItemCondition,
    TileItemHarvest,
    TileItemProperties,
} from "../lib";
import oreItems from "../lib/groups/tile.oreItem";

export default [
    ...[
        {
            id: "coal",
            harvestLevel: 0,
            blockHarvest: new TileItemHarvest(
                0.58,
                1,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new TileItemHarvest(
                0.38,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
        },
        {
            id: "copper",
            harvestLevel: 0,
            blockHarvest: new TileItemHarvest(
                0.68,
                1,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new TileItemHarvest(
                0.42,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "iron",
            harvestLevel: 0,
            blockHarvest: new TileItemHarvest(
                0.78,
                1,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new TileItemHarvest(
                0.48,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "gold",
            harvestLevel: 0,
            blockHarvest: new TileItemHarvest(
                0.88,
                1,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new TileItemHarvest(
                0.56,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "platinum",
            harvestLevel: 0,
            blockHarvest: new TileItemHarvest(
                0.98,
                1,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new TileItemHarvest(
                0.72,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new TileItemCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
    ].map(
        ({
            id,
            harvestLevel,
            blockHarvest,
            blockSFX,
            oreHarvest,
            oreSFX,
            hasRawItem,
        }) =>
            oreItems(
                id,
                harvestLevel,
                [TileItemProperties.IsTile],
                blockHarvest,
                blockSFX,
                [
                    TileItemProperties.CanFlip,
                    TileItemProperties.CanMirror,
                    TileItemProperties.IsTile,
                ],
                oreHarvest,
                oreSFX,
                hasRawItem,
            ),
    ),
];
