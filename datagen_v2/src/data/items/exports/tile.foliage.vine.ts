import { DatagenReturnData } from "../../../lib";
import {
    ItemParticle,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
    TileItemDrop,
    TileItemHarvest,
    TileItemPlacement,
    TileItemProperties,
} from "../lib";

export default [
    /* vines */
    ...[
        {
            id: "vine",
            particleColour: "#phantasia:tile/particle_colour/plant",
        },
        {
            id: "lumin_vine",
            particleColour: "#phantasia:tile/particle_colour/plant",
            scripts: {
                onUse: [new ItemScript("@phantasia:tile/nature/lumin_vine_use")],
                onRandomTick: [new ItemScript("@phantasia:tile/nature/lumin_vine_grow")],
            },
        },
    ].map(
        ({ id, particleColour, scripts }) => {
            const item = new TileItem(
                ItemType.Untouchable,
                `phantasia:item/${id}`,
                "#phantasia:item/generic/inventory_default",
                [
                    TileItemProperties.CanMirror,
                    TileItemProperties.CanFlip,
                    TileItemProperties.IsFoliage,
                ],
            )
                .setTileDrops([new TileItemDrop(`phantasia:${id}`)])
                .setTileHarvest(
                    new TileItemHarvest(
                        0.38,
                        0,
                        new ItemParticle(
                            particleColour as any,
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
                .setTileAudioProperties(
                    new TileItemAudioProperties(0.05, 0.0),
                );

            if (scripts?.onUse) {
                item.addOnUse(scripts.onUse);
            }

            if (scripts?.onRandomTick) {
                item.setTileOnRandomTick(scripts.onRandomTick);
            }

            return new DatagenReturnData(`${id}.json`, item);
        }
    ),
];
