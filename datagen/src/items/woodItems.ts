import {
    Item,
    ItemSprite,
    ItemInventory,
    ItemDurability,
    ItemType,
} from "../items";

const {
    default: tileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTileProperties,
    ItemTileSFX,
} = import.meta.require("./tileItem");

const { default: toolItem } = import.meta.require("./toolItem");

export default (
    id: string,
    leavesParticleId: string | string[],
    logParticleId: string | string[],
    plankParticleId: string | string[],
) => [
    tileItem(
        id,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        undefined,
        [new ItemTileDrop(`phantasia:${id}`)],
        new ItemTileHarvest(
            0.56,
            1,
            new ItemTileParticle(
                logParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
    tileItem(
        `${id}_chest`,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        undefined,
        [new ItemTileDrop(`phantasia:${id}_chest`)],
        new ItemTileHarvest(
            0.56,
            1,
            new ItemTileParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
    tileItem(
        `${id}_leaves`,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        [
            ItemTileProperties.CanFlip,
            ItemTileProperties.CanMirror,
            ItemTileProperties.IsTile,
        ],
        [new ItemTileDrop(`phantasia:${id}_leaves`)],
        new ItemTileHarvest(
            0.44,
            1,
            new ItemTileParticle(
                leavesParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
    toolItem(
        `${id}_pickaxe`,
        1,
        1,
        73,
        "#phantasia:item/generic/inventory_tool",
    ),
    tileItem(
        `${id}_planks`,
        ItemType.Solid,
        "#phantasia:item/generic/inventory_tile",
        ItemTileProperties.IsTile,
        [new ItemTileDrop(`phantasia:${id}_planks`)],
        new ItemTileHarvest(
            0.44,
            1,
            new ItemTileParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
    tileItem(
        `${id}_planks_wall`,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        ItemTileProperties.IsTile,
        [new ItemTileDrop(`phantasia:${id}_planks_wall`)],
        new ItemTileHarvest(
            0.44,
            1,
            new ItemTileParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),

    toolItem(
        `${id}_shovel`,
        1,
        1,
        65,
        "#phantasia:item/generic/inventory_tool",
    ),
    tileItem(
        `${id}_workbench`,
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_tile",
        undefined,
        [new ItemTileDrop(`phantasia:${id}_workbench`)],
        new ItemTileHarvest(
            0.56,
            1,
            new ItemTileParticle(
                plankParticleId,
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/axe"),
        ),
        undefined,
        new ItemTileSFX("#phantasia:tile/sfx/wood"),
    ),
];
