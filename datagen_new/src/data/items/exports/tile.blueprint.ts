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
                new ItemScript("@phantasia:open_menu", [
                    {
                        type: "button",
                        x: 56,
                        y: 56,
                        on_select_release: "exit",
                    },
                    {
                        type: "anchor",
                        x: 480,
                        y: 84,
                        text: "phantasia:tile.structure_blueprint.structure_id",
                    },
                    {
                        type: "textbox_string",
                        x: 480,
                        y: 132,
                        width: 17,
                        height: 3,
                        placeholder: "ID",
                        max_length: 80,
                    },
                ]),
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
                new ItemScript("@phantasia:open_menu", [
                    {
                        type: "button",
                        x: 56,
                        y: 56,
                        on_select_release: "exit",
                    },
                    {
                        type: "anchor",
                        x: 480,
                        y: 84,
                        text: "phantasia:tile.structure_blueprint.structure_id",
                    },
                    {
                        type: "textbox_string",
                        x: 480,
                        y: 132,
                        width: 17,
                        height: 3,
                        placeholder: "ID",
                        max_length: 80,
                        component: "id",
                    },
                    {
                        type: "anchor",
                        x: 480,
                        y: 248,
                        text: "phantasia:tile.structure_blueprint.offset",
                    },
                    {
                        type: "textbox_string",
                        x: 408,
                        y: 552,
                        width: 17,
                        height: 3,
                        placeholder:
                            "phantasia:tile.structure_blueprint.xoffset",
                        minNumber: -128,
                        maxNumber: 127,
                        component: "xoffset",
                    },
                    {
                        type: "textbox_string",
                        x: 408,
                        y: 552,
                        width: 17,
                        height: 3,
                        placeholder:
                            "phantasia:tile.structure_blueprint.yoffset",
                        minNumber: -128,
                        maxNumber: 127,
                        component: "yoffset",
                    },
                    {
                        type: "anchor",
                        x: 480,
                        y: 316,
                        text: "phantasia:tile.structure_blueprint.scale",
                    },
                    {
                        type: "textbox_string",
                        x: 408,
                        y: 552,
                        width: 17,
                        height: 3,
                        placeholder:
                            "phantasia:tile.structure_blueprint.xscale",
                        minNumber: 1,
                        maxNumber: 255,
                        component: "xscale",
                    },
                    {
                        type: "textbox_string",
                        x: 408,
                        y: 552,
                        width: 17,
                        height: 3,
                        placeholder:
                            "phantasia:tile.structure_blueprint.yscale",
                        minNumber: 1,
                        maxNumber: 255,
                        component: "yscale",
                    },
                    {
                        type: "button",
                        x: 480,
                        y: 480,
                        width: 17,
                        height: 3,
                        text: "Export",
                        on_select_release: "@phantasia:export_structure",
                    },
                ]),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setTileAudioProperties(new TileItemAudioProperties(0.65, 0.5)),
    ),
];
