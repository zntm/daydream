import { Doc, Table } from "../../../lib";

export const syntax = new Doc("UI Syntax")
    .add("The `.ui` language is a declarative markup used to define screens and components. Files are loaded via `ui_load(\"path/to/file.ui\")`.")
    .section("Element Declaration")
    .add("```\n@type(name) {\n    property = value\n}\n```")
    .add("Elements can be nested:\n\n```\n@area(container) {\n    size = (200, 100)\n\n    @button(btn_confirm) {\n        text = \"OK\"\n        size = (80, 24)\n    }\n}\n```")
    .section("Variables")
    .add("Declare reusable values with `var`:\n\n```\nvar padding = 8\nvar btn_size = (160, 32)\n\n@button(btn_play) {\n    size = btn_size\n}\n```")
    .section("Values")
    .add("### Numbers\n\n```\nsize = (160, 32)\nalpha = 0.5\nspacing = 12\n```")
    .add("### Percentages\n\nResolves relative to the parent container:\n\n```\nposition = (50%, 50%)\n```")
    .add("### Colors\n\nUse hex color literals:\n\n```\nbackground = #1a1a2e\nbackground = #ff000080    // with alpha\n```")
    .section("Positioning & Anchors")
    .add("Coordinates in the UI system are relative to the parent container's dimensions and the element's chosen anchor. The system resolves coordinates using the following rule:\n\n`Resolved Pixel = (Parent Size * Percentage) + Absolute Offset`")
    .add("### Anchor Points\n\nEvery element has an anchor point. By default, this is `ORIGIN_TOP_LEFT`. When you set a `position`, you are setting the offset relative to that anchor.")
    .add("### Percentage Values\n\nPercentages allow for responsive layouts. They are resolved relative to the parent's size at runtime:\n\n* `position = (50%, 50%)` — Positions the element relative to the center of the parent.\n* `size = (100% - 32, 24)` — Makes the element fill the parent width minus a margin.")
    .add("### ORIGIN Constants\n\nThese are shorthands for specific percentage tuples:")
    .table(["Constant", "Equivalent Tuple"], (t: Table) => {
        t.addRow(["`ORIGIN_TOP_LEFT`", "`(0, 0)`"]);
        t.addRow(["`ORIGIN_TOP_CENTER`", "`(50%, 0)`"]);
        t.addRow(["`ORIGIN_TOP_RIGHT`", "`(100%, 0)`"]);
        t.addRow(["`ORIGIN_CENTER_LEFT`", "`(0, 50%)`"]);
        t.addRow(["`ORIGIN_CENTER`", "`(50%, 50%)`"]);
        t.addRow(["`ORIGIN_CENTER_RIGHT`", "`(100%, 50%)`"]);
        t.addRow(["`ORIGIN_BOTTOM_LEFT`", "`(0, 100%)`"]);
        t.addRow(["`ORIGIN_BOTTOM_CENTER`", "`(50%, 100%)`"]);
        t.addRow(["`ORIGIN_BOTTOM_RIGHT`", "`(100%, 100%)`"]);
    })
    .add("### Tuple Math\n\nYou can perform arithmetic on `(x, y)` tuples and ORIGIN constants:")
    .add("```\n// Center the element but move it 16 pixels up\nposition = ORIGIN_CENTER + (0, -16)\n\n// Position relative to a percentage with a fixed pixel offset\nposition = (100%, 0) + (-8, 8)\n```")
    .section("Special Value Prefixes")
    .add("### `$sprite(name)` — Sprite Reference\n\nResolves a sprite asset by name:\n\n```\nsprite_index = $sprite(spr_Menu_Button_Main)\nicon = $sprite(spr_Inventory_Icon) {\n    image_index = 3\n}\n```")
    .add("### `$surface(name)` — Surface Reference\n\nResolves a named surface at runtime:\n\n```\nsource = $surface(surf_world)\n```")
    .add("### `$\"key\"` — Localization Key\n\nLooks up a localized string:\n\n```\ntext = $\"menu.play\"\n```")
    .add("### `@\"script_id\"` — Script Reference\n\nReferences a proglang script by ID:\n\n```\non_select = @\"my_mod:on_play_pressed\"\n```")
    .add("### `*binding` — Data Binding\n\nBinds to the link context:\n\n```\ntext = *player_name\n```")
    .section("ORIGIN Constants")
    .table(["Constant", "Anchor"], (t: Table) => {
        t.addRow(["`ORIGIN_TOP_LEFT`", "Top-left corner"]);
        t.addRow(["`ORIGIN_TOP_CENTER`", "Top-center"]);
        t.addRow(["`ORIGIN_TOP_RIGHT`", "Top-right corner"]);
        t.addRow(["`ORIGIN_CENTER_LEFT`", "Middle-left"]);
        t.addRow(["`ORIGIN_CENTER`", "Center"]);
        t.addRow(["`ORIGIN_CENTER_RIGHT`", "Middle-right"]);
        t.addRow(["`ORIGIN_BOTTOM_LEFT`", "Bottom-left"]);
        t.addRow(["`ORIGIN_BOTTOM_CENTER`", "Bottom-center"]);
        t.addRow(["`ORIGIN_BOTTOM_RIGHT`", "Bottom-right"]);
    })
    .toString();
