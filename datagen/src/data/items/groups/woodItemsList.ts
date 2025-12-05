import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import {
    ItemTileCondition,
    ItemTileDrop,
    ItemTileHarvest,
    ItemTileParticle,
    TileItem,
} from "../lib/TileItem";

const { default: woodItems } = import.meta.require("./woodItems");

export default [
    ...[
        {
            id: "birch",
            leavesParticleId: ["#051417", "#041013"],
            logParticleId: ["#4F5263", "#3E4051"],
        },
        {
            id: "mangrove",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#4D2D0B", "#3F2207"],
        },
        {
            id: "oak",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#3B160A", "#2D0B04"],
        },
        {
            id: "pine",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#381D1E", "#301A1C"],
        },
    ].map(({ id, leavesParticleId, logParticleId }): any =>
        woodItems(
            id,
            leavesParticleId,
            logParticleId,
            `#phantasia:tile/particle_colour/plank_${id}`,
        ),
    ),
    new DatagenReturnData(
        `generated/data/items/mangrove_roots.json`,
        new TileItem(
            ItemType.Solid,
            `phantasia:item/mangrove_roots`,
            "#phantasia:item/generic/inventory_tile",
        )
            .setTileDrops([new ItemTileDrop(`phantasia:mangrove`)])
            .setTileHarvest(
                new ItemTileHarvest(
                    0.56,
                    1,
                    new ItemTileParticle(
                        ["#4D2D0B", "#3F2207"],
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                    new ItemTileCondition("#phantasia:item/type/axe"),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.4, 0.1),
    ),
];
