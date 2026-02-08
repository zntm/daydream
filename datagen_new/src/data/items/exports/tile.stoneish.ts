import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemType,
    TileItem,
    TileItemCondition,
    TileItemDrop,
    TileItemAudioProperties,
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
    ...[
        new StoneishItems(
            "phantasia",
            "dirt",
            new TileItemHarvest(
                0.36,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            "#phantasia:tile/sfx/dirt",
            new TileItemAudioProperties(0.15, 0.05),
        ),
        new StoneishItems(
            "phantasia",
            "moss",
            new TileItemHarvest(
                0.26,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            "#phantasia:tile/sfx/foliage",
            new TileItemAudioProperties(0.05, 0),
        ),
        new StoneishItems(
            "phantasia",
            "lumin_moss",
            new TileItemHarvest(
                0.26,
                0,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            "#phantasia:tile/sfx/foliage",
            new TileItemAudioProperties(0.05, 0),
        ),
    ].flatMap(({ namespace, id, harvest, sfx, audioProperties }) =>
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
    ),
    ...[
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
            ),
            "#phantasia:tile/sfx/stone",
            new TileItemAudioProperties(0.7, 0.6),
        ),
        new StoneishItems(
            "phantasia",
            "sandstone",
            new TileItemHarvest(
                0.34,
                2,
                new ItemParticle(
                    "#phantasia:tile/particle_colour/sand",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            "#phantasia:tile/sfx/stone",
            new TileItemAudioProperties(0.7, 0.6),
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
            new TileItemAudioProperties(0.7, 0.6),
        ),
    ].flatMap(({ namespace, id, harvest, sfx, audioProperties }) => [
        ...tileBlockWallItems(
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
        ...tileBlockWallItems(
            namespace,
            `${id}_bricks`,
            [TileItemProperties.IsTile],
            harvest,
            sfx,
            audioProperties,
        ),
    ]),
    new DatagenReturnData(
        "sand.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/sand",
            "#phantasia:item/generic/inventory_default",
            [
                TileItemProperties.CanFlip,
                TileItemProperties.CanMirror,
                TileItemProperties.IsTile,
            ],
        )
            .setTileAudioProperties(new TileItemAudioProperties(0.2, 0))
            .setTileDrops([
                new TileItemDrop("phantasia:sand").setCondition(
                    new TileItemCondition("#phantasia:item/type/shovel"),
                ),
            ])
            .setTileHarvest(
                new TileItemHarvest(
                    0.36,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/sand",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/sand"),
    ),
    new DatagenReturnData(
        "glass.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/glass",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([
                new TileItemDrop("phantasia:glass").setCondition(
                    new TileItemCondition("#phantasia:item/type/pickaxe", 1),
                ),
            ])
            .setTileHarvest(
                new TileItemHarvest(
                    0.08,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/pickaxe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
    new DatagenReturnData(
        "furnace.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/furnace",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([
                new TileItemDrop("phantasia:furnace").setCondition(
                    new TileItemCondition("#phantasia:item/type/pickaxe", 1),
                ),
            ])
            .setTileHarvest(
                new TileItemHarvest(
                    0.36,
                    0,
                    new ItemParticle(
                        "#phantasia:tile/particle_colour/stone",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new TileItemCondition("#phantasia:item/type/pickaxe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
    ...["", "taiga", "swamp"].map((id) => {
        const fullId = id !== "" ? `grass_block_${id}` : "grass_block";

        return new DatagenReturnData(
            `${fullId}.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${fullId}`,
                "#phantasia:item/generic/inventory_tile",
                [TileItemProperties.CanMirror, TileItemProperties.IsTile],
            )
                .setTileDrops([new TileItemDrop(`phantasia:dirt`)])
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
        );
    }),
];
