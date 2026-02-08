import { DatagenReturnData } from "../../../lib";
import {
    ItemComponent,
    ItemScript,
    ItemType,
    TileItem,
    TileItemAudioProperties,
} from "../lib";

export default [
    new DatagenReturnData(
        "loot_blueprint.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/loot_blueprint",
            "#phantasia:item/generic/inventory_default",
        )
            .addTileComponent("id", ItemComponent.string("", 0, 80))
            .addTileComponent("turns_into", ItemComponent.string("", 0, 80))
            .addOnUse([
                new ItemScript("@phantasia:open_ui", {
                    ui: "ui/loot_blueprint.ui",
                    definition: "loot_blueprint_menu",
                    bindings: {
                        id: "component:id",
                        turns_into: "component:turns_into",
                    },
                }),
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
            .addTileComponent("id", ItemComponent.string("", 0, 80))
            .addTileComponent("turns_into", ItemComponent.string("", 0, 80))
            .addTileComponent("xoffset", ItemComponent.s8(0, -128, 127))
            .addTileComponent("yoffset", ItemComponent.s8(0, -128, 127))
            .addTileComponent("xscale", ItemComponent.u8(1, 1, 255))
            .addTileComponent("yscale", ItemComponent.u8(1, 1, 255))
            .addOnUse([
                new ItemScript("@phantasia:open_ui", {
                    ui: "ui/structure_blueprint.ui",
                    definition: "structure_blueprint_menu",
                    bindings: {
                        id: "component:id",
                        turns_into: "component:turns_into",
                        xoffset: "component:xoffset",
                        yoffset: "component:yoffset",
                        xscale: "component:xscale",
                        yscale: "component:yscale",
                    },
                }),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
    ),
];

