# UI Syntax

The `.ui` language is a declarative markup used to define screens and components. Files are loaded via `ui_load("path/to/file.ui")`.

## Element Declaration

```
@type(name) {
    property = value
}
```

Elements can be nested:

```
@area(container) {
    size = (200, 100)

    @button(btn_confirm) {
        text = "OK"
        size = (80, 24)
    }
}
```

## Variables

Declare reusable values with `var`:

```
var padding = 8
var btn_size = (160, 32)

@button(btn_play) {
    size = btn_size
}
```

## Values

### Numbers

```
size = (160, 32)
alpha = 0.5
spacing = 12
```

### Percentages

Resolves relative to the parent container:

```
position = (50%, 50%)
```

### Colors

Use hex color literals:

```
background = #1a1a2e
background = #ff000080    // with alpha
```

## Positioning & Anchors

Coordinates in the UI system are relative to the parent container's dimensions and the element's chosen anchor. The system resolves coordinates using the following rule:

`Resolved Pixel = (Parent Size * Percentage) + Absolute Offset`

### Anchor Points

Every element has an anchor point. By default, this is `ORIGIN_TOP_LEFT`. When you set a `position`, you are setting the offset relative to that anchor.

### Percentage Values

Percentages allow for responsive layouts. They are resolved relative to the parent's size at runtime:

* `position = (50%, 50%)` — Positions the element relative to the center of the parent.
* `size = (100% - 32, 24)` — Makes the element fill the parent width minus a margin.

### ORIGIN Constants

These are shorthands for specific percentage tuples:

| Constant               | Equivalent Tuple |
| ---------------------- | ---------------- |
| `ORIGIN_TOP_LEFT`      | `(0, 0)`         |
| `ORIGIN_TOP_CENTER`    | `(50%, 0)`       |
| `ORIGIN_TOP_RIGHT`     | `(100%, 0)`      |
| `ORIGIN_CENTER_LEFT`   | `(0, 50%)`       |
| `ORIGIN_CENTER`        | `(50%, 50%)`     |
| `ORIGIN_CENTER_RIGHT`  | `(100%, 50%)`    |
| `ORIGIN_BOTTOM_LEFT`   | `(0, 100%)`      |
| `ORIGIN_BOTTOM_CENTER` | `(50%, 100%)`    |
| `ORIGIN_BOTTOM_RIGHT`  | `(100%, 100%)`   |

### Tuple Math

You can perform arithmetic on `(x, y)` tuples and ORIGIN constants:

```
// Center the element but move it 16 pixels up
position = ORIGIN_CENTER + (0, -16)

// Position relative to a percentage with a fixed pixel offset
position = (100%, 0) + (-8, 8)
```

## Special Value Prefixes

### `$sprite(name)` — Sprite Reference

Resolves a sprite asset by name:

```
sprite_index = $sprite(spr_Menu_Button_Main)
icon = $sprite(spr_Inventory_Icon) {
    image_index = 3
}
```

### `$surface(name)` — Surface Reference

Resolves a named surface at runtime:

```
source = $surface(surf_world)
```

### `$"key"` — Localization Key

Looks up a localized string:

```
text = $"menu.play"
```

### `@"script_id"` — Script Reference

References a proglang script by ID:

```
on_select = @"my_mod:on_play_pressed"
```

### `*binding` — Data Binding

Binds to the link context:

```
text = *player_name
```

## ORIGIN Constants

| Constant               | Anchor           |
| ---------------------- | ---------------- |
| `ORIGIN_TOP_LEFT`      | Top-left corner  |
| `ORIGIN_TOP_CENTER`    | Top-center       |
| `ORIGIN_TOP_RIGHT`     | Top-right corner |
| `ORIGIN_CENTER_LEFT`   | Middle-left      |
| `ORIGIN_CENTER`        | Center           |
| `ORIGIN_CENTER_RIGHT`  | Middle-right     |
| `ORIGIN_BOTTOM_LEFT`   | Bottom-left      |
| `ORIGIN_BOTTOM_CENTER` | Bottom-center    |
| `ORIGIN_BOTTOM_RIGHT`  | Bottom-right     |
