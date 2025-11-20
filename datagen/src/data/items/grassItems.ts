import { ItemType } from "./lib/ItemType";
import tileItem, {
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTileProperties,
    ItemTileSFX,
} from "./tileItem";

export default [
    ...["", "dry", "swamp", "taiga"]
        .map((id: string) => {
            id = id !== "" ? `grass_${id}` : "grass";

            return ["short", "tall"].map((type: string) =>
                tileItem(
                    `${type}_${id}`,
                    ItemType.Untouchable,
                    "#phantasia:item/generic/inventory_default",
                    [
                        ItemTileProperties.CanMirror,
                        ItemTileProperties.IsFoliage,
                    ],
                    [new ItemTileDrop(`phantasia:${type}_${id}`)],
                    new ItemTileHarvest(
                        0.38,
                        0,
                        new ItemTileParticle(
                            "#phantasia:tile/particle_colour/plant",
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                    ),
                    new ItemTilePlacement().setCondition(
                        "#phantasia:tile/placement/condition_plant",
                    ),
                    "#phantasia:tile/sfx/foliage",
                ),
            );
        })
        .flat(),
    ...["", "taiga", "swamp"].map((id) => {
        id = id !== "" ? `grass_block_${id}` : "grass_block";

        return tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsTile],
            [new ItemTileDrop(`phantasia:dirt`)],
            new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            undefined,
            "#phantasia:tile/sfx/dirt",
        );
    }),
];
