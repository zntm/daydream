import { Doc, Table } from "../../../lib";

const elements = new Doc("UI Elements")
    .add("UI elements are declared in `.ui` files using the declarative UI language.")
    .section("@area(name)")
    .add("A transparent container for grouping and layout. Does not render anything by default.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`position`", "tuple", "Position relative to parent/anchor"]);
        t.addRow(["`size`", "tuple", "`(width, height)` in pixels"]);
        t.addRow(["`anchor`", "tuple", 'Anchor point `("left", "top")` etc']);
        t.addRow(["`layout`", "enum", "Child layout mode"]);
        t.addRow(["`spacing`", "number", "Gap between children (layout mode)"]);
        t.addRow(["`padding`", "number", "Inner padding (all sides)"]);
        t.addRow(["`background`", "color", "Background fill color `#RRGGBB`"]);
        t.addRow(["`fade_top`", "number", "Top edge fade distance in pixels"]);
        t.addRow(["`fade_bottom`", "number", "Bottom edge fade distance in pixels"]);
        t.addRow(["`fade_left`", "number", "Left edge fade distance in pixels"]);
        t.addRow(["`fade_right`", "number", "Right edge fade distance in pixels"]);
    })
    .section("@button(name)")
    .add("An interactive button with click/hover states.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`text`", "string", "Label text"]);
        t.addRow(["`size`", "tuple", "`(width, height)` in pixels"]);
        t.addRow(["`position`", "tuple", "Position relative to parent"]);
        t.addRow(["`colour`", "color", "Text color"]);
        t.addRow(["`sprite_index`", "sprite", "Background sprite `$sprite(name)`"]);
        t.addRow(["`icon`", "sprite", "Icon sprite `$sprite(name)`"]);
        t.addRow(["`icon_index`", "number", "Icon frame index"]);
        t.addRow(["`on_select`", "script", 'Event: pressed `@"script_id"`']);
        t.addRow(["`on_select_release`", "script", 'Event: released `@"script_id"`']);
        t.addRow(["`on_select_hold`", "script", 'Event: held `@"script_id"`']);
    })
    .section("@text(name)")
    .add("Displays a text label. Supports data bindings for dynamic text.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`text`", "string", 'Static text or `$"loca_key"`']);
        t.addRow(["`colour`", "color", "Text color `#RRGGBB`"]);
        t.addRow(["`alpha`", "number", "Opacity (0–1)"]);
        t.addRow(["`text_scale`", "number", "Scale multiplier"]);
        t.addRow(["`halign`", "string", 'Horizontal align (`"left"`, `"center"`, `"right"`)']);
        t.addRow(["`valign`", "string", 'Vertical align (`"top"`, `"middle"`, `"bottom"`)']);
    })
    .section("@image(name)")
    .add("Displays a sprite or surface.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`source`", "sprite", "Sprite `$sprite(name)` or surface `$surface(name)`"]);
        t.addRow(["`image_index`", "number", "Frame index"]);
        t.addRow(["`image_xscale`", "number", "Horizontal scale"]);
        t.addRow(["`image_yscale`", "number", "Vertical scale"]);
        t.addRow(["`image_angle`", "number", "Rotation in degrees"]);
        t.addRow(["`colour`", "color", "Tint color"]);
        t.addRow(["`alpha`", "number", "Opacity (0–1)"]);
    })
    .section("@window(name)")
    .add("A movable container with a title bar.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`title`", "string", "Window title text"]);
        t.addRow(["`size`", "tuple", "`(width, height)` in pixels"]);
        t.addRow(["`position`", "tuple", "Position"]);
        t.addRow(["`movable`", "bool", "Whether the window can be dragged"]);
        t.addRow(["`closeable`", "bool", "Whether a close button appears"]);
    })
    .section("@slider(name)")
    .add("A draggable value slider.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)` in pixels"]);
        t.addRow(["`min_value`", "number", "Minimum value"]);
        t.addRow(["`max_value`", "number", "Maximum value"]);
        t.addRow(["`value`", "number", "Initial value"]);
        t.addRow(["`step`", "number", "Step size (0 = continuous)"]);
        t.addRow(["`on_change`", "script", 'Event: drag released `@"id"`']);
        t.addRow(["`on_drag`", "script", 'Event: dragging `@"id"`']);
    })
    .section("@bar(name)")
    .add("A visual progress/stat bar (non-interactive).")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
        t.addRow(["`min_value`", "number", "Minimum value"]);
        t.addRow(["`max_value`", "number", "Maximum value"]);
        t.addRow(["`value`", "number", "Current value"]);
    })
    .section("@textbox(name)")
    .add("A single-line text input field.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
        t.addRow(["`on_change`", "script", 'Event: text changed `@"id"`']);
        t.addRow(["`on_submit`", "script", 'Event: enter pressed `@"id"`']);
    })
    .section("@slot(name)")
    .add("An inventory slot that displays an item icon.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`inventory_name`", "string", "Inventory to bind to"]);
        t.addRow(["`slot_index`", "number", "Index within the inventory"]);
    })
    .section("@radio_button(name)")
    .add("A toggle button, part of a mutually exclusive group.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`text`", "string", "Label text"]);
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
        t.addRow(["`on_select`", "script", "Event: selected"]);
    })
    .section("@dropdown(name)")
    .add("A dropdown select control.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
        t.addRow(["`on_change`", "script", "Event: selection changed"]);
    })
    .section("@scroll_area(name)")
    .add("A vertically scrollable container.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)` in pixels"]);
        t.addRow(["`layout`", "enum", "Child layout mode"]);
        t.addRow(["`spacing`", "number", "Gap between children"]);
    })
    .section("@popup(name)")
    .add("A floating overlay panel.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
        t.addRow(["`position`", "tuple", "Position"]);
    })
    .section("@page(name)")
    .add("A named page within a tabbed layout.")
    .table(["Property", "Type", "Description"], (t: Table) => {
        t.addRow(["`size`", "tuple", "`(width, height)`"]);
    })
    .section("@line(name) / @line_path(name)")
    .add("Renders a line or multi-point path.")
    .section("Layout Modes")
    .table(["Enum", "Description"], (t: Table) => {
        t.addRow(["`LAYOUT_NONE`", "Manual positioning (default)"]);
        t.addRow(["`LAYOUT_VERTICAL`", "Stack children top-to-bottom"]);
        t.addRow(["`LAYOUT_HORIZONTAL`", "Stack children left-to-right"]);
        t.addRow(["`LAYOUT_GRID`", "Grid layout (wraps at `grid_columns`)"]);
    })
    .section("Anchor Values")
    .add('**`anchor_x`:** `"left"` · `"center"` · `"right"`')
    .add('**`anchor_y`:** `"top"` · `"middle"` · `"bottom"`')
    .toString();

export { elements };
