import {
    ItemTileCondition,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileProperties,
} from "./tileItem";

const { default: oreItems } = import.meta.require("./oreItems");

export default [
    {
        id: "coal",
        harvestLevel: 0,
        blockHarvest: new ItemTileHarvest(
            0.58,
            1,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        blockSFX: "#phantasia:tile/sfx/stone",
        oreHarvest: new ItemTileHarvest(
            0.38,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        oreSFX: "#phantasia:tile/sfx/stone",
    },
    {
        id: "copper",
        harvestLevel: 0,
        blockHarvest: new ItemTileHarvest(
            0.68,
            1,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        blockSFX: "#phantasia:tile/sfx/stone",
        oreHarvest: new ItemTileHarvest(
            0.42,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        oreSFX: "#phantasia:tile/sfx/stone",
        hasRawItem: true,
    },
    {
        id: "iron",
        harvestLevel: 0,
        blockHarvest: new ItemTileHarvest(
            0.78,
            1,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        blockSFX: "#phantasia:tile/sfx/stone",
        oreHarvest: new ItemTileHarvest(
            0.48,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        oreSFX: "#phantasia:tile/sfx/stone",
        hasRawItem: true,
    },
    {
        id: "gold",
        harvestLevel: 0,
        blockHarvest: new ItemTileHarvest(
            0.88,
            1,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        blockSFX: "#phantasia:tile/sfx/stone",
        oreHarvest: new ItemTileHarvest(
            0.56,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        oreSFX: "#phantasia:tile/sfx/stone",
        hasRawItem: true,
    },
    {
        id: "platinum",
        harvestLevel: 0,
        blockHarvest: new ItemTileHarvest(
            0.98,
            1,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        blockSFX: "#phantasia:tile/sfx/stone",
        oreHarvest: new ItemTileHarvest(
            0.72,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        oreSFX: "#phantasia:tile/sfx/stone",
        hasRawItem: true,
    }

]
    .map(
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
                ItemTileProperties.IsTile,
                blockHarvest,
                blockSFX,
                [
                    ItemTileProperties.CanFlip,
                    ItemTileProperties.CanMirror,
                    ItemTileProperties.IsTile,
                ],
                oreHarvest,
                oreSFX,
                hasRawItem,
            ),
    )
    .flat()