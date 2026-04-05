# UI Elements

UI elements are declared in `.ui` files using the declarative UI language.

## @area(name)

A transparent container for grouping and layout. Does not render anything by default.

| Property      | Type   | Description                         |
| ------------- | ------ | ----------------------------------- |
| `position`    | tuple  | Position relative to parent/anchor  |
| `size`        | tuple  | `(width, height)` in pixels         |
| `anchor`      | tuple  | Anchor point `("left", "top")` etc  |
| `layout`      | enum   | Child layout mode                   |
| `spacing`     | number | Gap between children (layout mode)  |
| `padding`     | number | Inner padding (all sides)           |
| `background`  | color  | Background fill color `#RRGGBB`     |
| `fade_top`    | number | Top edge fade distance in pixels    |
| `fade_bottom` | number | Bottom edge fade distance in pixels |
| `fade_left`   | number | Left edge fade distance in pixels   |
| `fade_right`  | number | Right edge fade distance in pixels  |

## @button(name)

An interactive button with click/hover states.

| Property            | Type   | Description                       |
| ------------------- | ------ | --------------------------------- |
| `text`              | string | Label text                        |
| `size`              | tuple  | `(width, height)` in pixels       |
| `position`          | tuple  | Position relative to parent       |
| `colour`            | color  | Text color                        |
| `sprite_index`      | sprite | Background sprite `$sprite(name)` |
| `icon`              | sprite | Icon sprite `$sprite(name)`       |
| `icon_index`        | number | Icon frame index                  |
| `on_select`         | script | Event: pressed `@"script_id"`     |
| `on_select_release` | script | Event: released `@"script_id"`    |
| `on_select_hold`    | script | Event: held `@"script_id"`        |

## @text(name)

Displays a text label. Supports data bindings for dynamic text.

| Property     | Type   | Description                                        |
| ------------ | ------ | -------------------------------------------------- |
| `text`       | string | Static text or `$"loca_key"`                       |
| `colour`     | color  | Text color `#RRGGBB`                               |
| `alpha`      | number | Opacity (0–1)                                      |
| `text_scale` | number | Scale multiplier                                   |
| `halign`     | string | Horizontal align (`"left"`, `"center"`, `"right"`) |
| `valign`     | string | Vertical align (`"top"`, `"middle"`, `"bottom"`)   |

## @image(name)

Displays a sprite or surface.

| Property       | Type   | Description                                        |
| -------------- | ------ | -------------------------------------------------- |
| `source`       | sprite | Sprite `$sprite(name)` or surface `$surface(name)` |
| `image_index`  | number | Frame index                                        |
| `image_xscale` | number | Horizontal scale                                   |
| `image_yscale` | number | Vertical scale                                     |
| `image_angle`  | number | Rotation in degrees                                |
| `colour`       | color  | Tint color                                         |
| `alpha`        | number | Opacity (0–1)                                      |

## @window(name)

A movable container with a title bar.

| Property     | Type   | Description                       |
| ------------ | ------ | --------------------------------- |
| `title`      | string | Window title text                 |
| `size`       | tuple  | `(width, height)` in pixels       |
| `position`   | tuple  | Position                          |
| `movable`    | bool   | Whether the window can be dragged |
| `closeable`  | bool   | Whether a close button appears    |
| `background` | color  | Background fill                   |

## @slider(name)

A draggable value slider.

| Property            | Type   | Description                  |
| ------------------- | ------ | ---------------------------- |
| `size`              | tuple  | `(width, height)` in pixels  |
| `min` / `min_value` | number | Minimum value                |
| `max` / `max_value` | number | Maximum value                |
| `value`             | number | Initial value                |
| `step`              | number | Step size (0 = continuous)   |
| `on_change`         | script | Event: drag released `@"id"` |
| `on_drag`           | script | Event: dragging `@"id"`      |

## @bar(name)

A visual progress/stat bar (non-interactive).

| Property    | Type   | Description       |
| ----------- | ------ | ----------------- |
| `size`      | tuple  | `(width, height)` |
| `min_value` | number | Minimum value     |
| `max_value` | number | Maximum value     |
| `value`     | number | Current value     |

## @textbox(name)

A single-line text input field.

| Property      | Type   | Description                                       |
| ------------- | ------ | ------------------------------------------------- |
| `size`        | tuple  | `(width, height)`                                 |
| `placeholder` | string | Placeholder text                                  |
| `mode`        | string | Input mode (`string`, `integer`, `numeric`, etc.) |
| `text_length` | number | Maximum input length                              |
| `on_input`    | script | Event: text changed while focused `@"id"`         |
| `on_change`   | script | Event: text changed `@"id"`                       |
| `on_submit`   | script | Event: enter pressed `@"id"`                      |

## @slot(name)

An inventory slot that displays an item icon.

| Property         | Type   | Description                |
| ---------------- | ------ | -------------------------- |
| `inventory_name` | string | Inventory to bind to       |
| `slot_index`     | number | Index within the inventory |

## @radio_button(name)

A toggle or grouped radio control.

| Property            | Type   | Description            |
| ------------------- | ------ | ---------------------- |
| `text`              | string | Label text             |
| `size`              | tuple  | `(width, height)`      |
| `selected`          | bool   | Initial selected state |
| `group`             | string | Optional group name    |
| `on_select`         | script | Event: selected        |
| `on_select_release` | script | Event: toggled         |

## @dropdown(name)

A dropdown select control.

| Property                    | Type   | Description              |
| --------------------------- | ------ | ------------------------ |
| `size`                      | tuple  | `(width, height)`        |
| `choices` / `options`       | tuple  | Available options        |
| `choice_index` / `selected` | number | Current selected index   |
| `on_change`                 | script | Event: selection changed |

## @scroll_area(name)

A vertically scrollable container.

| Property  | Type   | Description                 |
| --------- | ------ | --------------------------- |
| `size`    | tuple  | `(width, height)` in pixels |
| `layout`  | enum   | Child layout mode           |
| `spacing` | number | Gap between children        |

## @popup(name)

A floating overlay panel.

| Property   | Type  | Description       |
| ---------- | ----- | ----------------- |
| `size`     | tuple | `(width, height)` |
| `position` | tuple | Position          |

## @line(name)

A straight line primitive.

| Property    | Type   | Description    |
| ----------- | ------ | -------------- |
| `start`     | tuple  | Start point    |
| `end`       | tuple  | End point      |
| `thickness` | number | Line thickness |
| `colour`    | color  | Line color     |

## @page(name)

A named page within a tabbed layout.

| Property | Type  | Description       |
| -------- | ----- | ----------------- |
| `size`   | tuple | `(width, height)` |

## @line(name) / @line_path(name)

Renders a line or multi-point path.

## Layout Modes

| Enum                | Description                           |
| ------------------- | ------------------------------------- |
| `LAYOUT_NONE`       | Manual positioning (default)          |
| `LAYOUT_VERTICAL`   | Stack children top-to-bottom          |
| `LAYOUT_HORIZONTAL` | Stack children left-to-right          |
| `LAYOUT_GRID`       | Grid layout (wraps at `grid_columns`) |

## Anchor Values

**`anchor_x`:** `"left"` · `"center"` · `"right"`

**`anchor_y`:** `"top"` · `"middle"` · `"bottom"`
