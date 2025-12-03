import { DatagenReturnData } from "../../../lib/DatagenReturnData";
import {
    ItemIntegerComponent,
    ItemStringComponent,
} from "../lib/ItemComponent";
import { ItemFunction } from "../lib/ItemFunction";
import { ItemType } from "../lib/ItemType";
import { TileItem } from "../lib/TileItem";

export default [
    new DatagenReturnData(
        "generated/data/items/loot_blueprint.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/loot_blueprint",
            "#phantasia:item/generic/inventory_default",
        )
            .addComponent("id", new ItemStringComponent("id", 80))
            .addComponent(
                "turns_into",
                new ItemStringComponent("turns_into", 80),
            )
            .addOnUse([
                new ItemFunction("phantasia:open_menu", [
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
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
    new DatagenReturnData(
        "generated/data/items/structure_blueprint.json",
        new TileItem(
            ItemType.Solid,
            "phantasia:item/structure_blueprint",
            "#phantasia:item/generic/inventory_default",
        )
            .addComponent("id", new ItemStringComponent("id", 80))
            .addComponent(
                "turns_into",
                new ItemStringComponent("turns_into", 80),
            )
            .addComponent(
                "xoffset",
                new ItemIntegerComponent("xoffset", -128, 127),
            )
            .addComponent(
                "yoffset",
                new ItemIntegerComponent("yoffset", -128, 127),
            )
            .addComponent("xscale", new ItemIntegerComponent("xscale", 1, 255))
            .addComponent("yscale", new ItemIntegerComponent("yscale", 1, 255))
            .addOnUse([
                new ItemFunction("phantasia:open_menu", [
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
                        on_select_release: "phantasia:export_structure",
                    },
                ]),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone"),
    ),
];
