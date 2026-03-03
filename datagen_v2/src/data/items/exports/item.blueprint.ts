import { DatagenReturnData } from "../../../lib";
import { ItemComponent } from "../lib";
import { ItemScript } from "../lib/ItemScript";
import { ItemType } from "../lib/ItemType";
import { TileItem, TileItemAudioProperties } from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "loot_blueprint.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/loot_blueprint",
            "#phantasia:item/generic/inventory_default",
        )
            .addTileComponent("id", ItemComponent.string("id", undefined, 80))
            .addTileComponent(
                "turns_into",
                ItemComponent.string("turns_into", undefined, 80),
            )
            .addOnUse([new ItemScript("@phantasia:ui/loot_blueprint")])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
    ),
    new DatagenReturnData(
        "structure_blueprint.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/structure_blueprint",
            "#phantasia:item/generic/inventory_default",
        )
            .addTileComponent("id", ItemComponent.string("id", undefined, 80))
            .addTileComponent(
                "turns_into",
                ItemComponent.string("turns_into", undefined, 80),
            )
            .addTileComponent("xoffset", ItemComponent.s16(0, -128, 127))
            .addTileComponent("yoffset", ItemComponent.s16(0, -128, 127))
            .addTileComponent("xscale", ItemComponent.u8(1, 1, 255))
            .addTileComponent("yscale", ItemComponent.u8(1, 1, 255))
            .addOnUse([
                new ItemScript("@phantasia:ui/structure_blueprint"),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
    ),
];
