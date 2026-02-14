import { DatagenReturnData } from "../../../lib";
import {
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    ItemParticle,
    TileItemPlacement,
    TileItemProperties,
} from "../lib";

export default [
    ...["", "dry", "swamp", "taiga"]
        .map((id: string) => {
            id = id !== "" ? `grass_${id}` : "grass";

            return ["short", "tall"].map(
                (type: string) =>
                    new DatagenReturnData(
                        `${type}_${id}.json`,
                        new TileItem(
                            ItemType.Untouchable,
                            `phantasia:item/${type}_${id}`,
                            "#phantasia:item/generic/inventory_default",
                            [
                                TileItemProperties.CanMirror,
                                TileItemProperties.IsFoliage,
                            ],
                        )
                            .setTileHarvest(
                                new TileItemHarvest(
                                    0.38,
                                    0,
                                    new ItemParticle(
                                        "#phantasia:tile/particle_colour/plant",
                                        "#phantasia:tile/generic/harvest_particle_frequency",
                                    ),
                                ),
                            )
                            .setTilePlacement(
                                new TileItemPlacement().setCondition(
                                    "#phantasia:tile/placement/condition_plant",
                                ),
                            )
                            .setTileSFX("#phantasia:tile/sfx/foliage")
                            .setTileAudioProperties(new TileItemAudioProperties(0.05, 0.0)),
                    ),
            );
        })
        .flat(),
    ...["", "taiga", "swamp"].map((id) => {
        id = id !== "" ? `grass_block_${id}` : "grass_block";

        return new DatagenReturnData(
            `${id}.json`,
            new TileItem(
                ItemType.Solid,
                `phantasia:item/${id}`,
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
                .setTileAudioProperties(new TileItemAudioProperties(0.15, 0.05)),
        );
    }),
];
