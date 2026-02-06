import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import { ItemType } from "../lib/ItemType";
import { ItemScript } from "../lib/ProgLang";
import {
    TileItem,
    TileItemDrop,
    TileItemHarvest,
    TileItemParticle,
} from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/campfire.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/campfire",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new TileItemDrop("phantasia:campfire")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new TileItemParticle(
                        "#phantasia:tile/particle_colour/wood",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.1, 0.0)
            .setTileLight("#EAC7A6")
            .setAnimationType("increment")
            .addOnRandomTick([
                new ItemScript(
                    "items/sfx_play",
                    {
                        id: "phantasia:sfx/tile/fire/ambient",
                    },
                    0.24,
                ),
            ]),
    ),

    new DatagenReturnData(
        "generated/data/items/torch.json",
        new TileItem(
            ItemType.Untouchable,
            "phantasia:item/torch",
            "#phantasia:item/generic/inventory_default",
        )
            .setTileDrops([new TileItemDrop("phantasia:torch")])
            .setTileHarvest(
                new TileItemHarvest(
                    0.38,
                    0,
                    new TileItemParticle(
                        "#phantasia:tile/particle_colour/twig",
                        "#phantasia:tile/generic/harvest_particle_frequency",
                    ),
                ),
            )
            .setTileSFX("#phantasia:tile/sfx/wood")
            .setAudioProperties(0.05, 0.0)
            .setTileLight("#D89172")
            .setAnimationType("increment")
            .addOnRandomTick([
                new ItemScript(
                    "items/sfx_play",
                    {
                        id: "phantasia:sfx/tile/fire/ambient",
                    },
                    0.18,
                ),
            ]),
    ),
];
