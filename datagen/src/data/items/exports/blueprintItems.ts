import { DatagenReturnData } from "../../../lib";
import {
    ItemIntegerComponent,
    ItemStringComponent,
} from "../lib/ItemComponent";
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
            .addTileComponent("id", new ItemStringComponent("id", 80))
            .addTileComponent(
                "turns_into",
                new ItemStringComponent("turns_into", 80),
            )
            .addOnUse([
                new ItemScript("@phantasia:ui/loot_blueprint"),
            ])
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
            .addTileComponent("id", new ItemStringComponent("id", 80))
            .addTileComponent(
                "turns_into",
                new ItemStringComponent("turns_into", 80),
            )
            .addTileComponent(
                "xoffset",
                new ItemIntegerComponent(0, -128, 127),
            )
            .addTileComponent(
                "yoffset",
                new ItemIntegerComponent(0, -128, 127),
            )
            .addTileComponent("xscale", new ItemIntegerComponent(1, 1, 255))
            .addTileComponent("yscale", new ItemIntegerComponent(1, 1, 255))
            .addOnUse([
                new ItemScript("@phantasia:ui/structure_blueprint"),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
    ),
];
