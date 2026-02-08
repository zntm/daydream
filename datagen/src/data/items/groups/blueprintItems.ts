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
                new ItemFunction("phantasia:ui/loot_blueprint"),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setAudioProperties(0.65, 0.5),
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
                new ItemIntegerComponent(0, -128, 127),
            )
            .addComponent(
                "yoffset",
                new ItemIntegerComponent(0, -128, 127),
            )
            .addComponent("xscale", new ItemIntegerComponent(1, 1, 255))
            .addComponent("yscale", new ItemIntegerComponent(1, 1, 255))
            .addOnUse([
                new ItemFunction("phantasia:ui/structure_blueprint"),
            ])
            .setTileSFX("#phantasia:tile/sfx/stone")
            .setAudioProperties(0.65, 0.5),
    ),
];
