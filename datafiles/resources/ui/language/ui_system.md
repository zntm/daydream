# UI System

The `.ui` markup language is a declarative system for defining game user interfaces. UI files describe element hierarchies with properties, expressions, and data bindings.

## Elements

Elements are declared with `@type(name)` followed by a block of properties and children.

```
@area(container) {
    position = (0, 0)
    size = (100, 50)

    @image(icon) {
        source = $sprite(spr_Icon)
    }
}
```

### Element Types

| Type | Description |
|------|-------------|
| `@area` | Generic container for layout and grouping |
| `@image` | Displays a sprite or image |
| `@bar` | Progress/stat bar with fill and empty states |
| `@slot` | Inventory slot with item display |
| `@text` | Text label |
| `@button` | Interactive button element |

## Properties

Properties are set with `key = value` syntax inside an element block.

```
@area(panel) {
    position = ORIGIN_TOP_LEFT + (10, 10)
    size = (200, 100)
    layout = LAYOUT_HORIZONTAL
}
```

### Common Properties

| Property | Type | Description |
|----------|------|-------------|
| `position` | vector | Position offset, can use anchor constants |
| `size` | vector | Width and height in pixels |
| `layout` | constant | Layout mode: `LAYOUT_HORIZONTAL`, `LAYOUT_VERTICAL` |
| `inventory_name` | string | Name of the inventory to bind to |
| `slot_index` | number | Index of the inventory slot |
| `source` | sprite | Image source for `@image` elements |
| `value` | number/binding | Current value for `@bar` elements |
| `max` | number/binding | Maximum value for `@bar` elements |
| `sprite_fill` | sprite | Fill sprite for bars |
| `sprite_empty` | sprite | Empty/background sprite for bars |
| `icon_sprite` | string | Sprite name for slot icons |
| `icon_index` | number | Sub-image index for slot icons |

## Values

### Numbers
```
size = (160, 16)
slot_index = 5
```

### Percentages
```
width = 50%
```

### Strings
```
inventory_name = "base"
```

### Undefined
```
text = undefined
```

### Vectors
Tuples are written with parentheses:
```
position = (10, 20)
slices = (1, 0, 4, 0)
```

### Constants

#### Anchor Constants
| Constant | Description |
|----------|-------------|
| `ORIGIN_TOP_LEFT` | Top-left corner |
| `ORIGIN_TOP_CENTER` | Top-center edge |
| `ORIGIN_TOP_RIGHT` | Top-right corner |
| `ORIGIN_MIDDLE_LEFT` | Middle-left edge |
| `ORIGIN_MIDDLE_CENTER` | Center |
| `ORIGIN_CENTER` | Center (alias of `ORIGIN_MIDDLE_CENTER`) |
| `ORIGIN_MIDDLE_RIGHT` | Middle-right edge |
| `ORIGIN_BOTTOM_LEFT` | Bottom-left corner |
| `ORIGIN_BOTTOM_CENTER` | Bottom-center edge |
| `ORIGIN_BOTTOM_RIGHT` | Bottom-right corner |

#### Layout Constants
| Constant | Description |
|----------|-------------|
| `LAYOUT_HORIZONTAL` | Arrange children left-to-right |
| `LAYOUT_VERTICAL` | Arrange children top-to-bottom |
| `LAYOUT_GRID` | Arrange children in a grid using `grid_columns` |
| `LAYOUT_NONE` | Disable automatic layout |

## Math Expressions

Properties support inline math with standard operators:

```
position = (index % 10 * 16, floor(index / 10) * 16)
slot_index = index + 10
```

### Operators
`+`, `-`, `*`, `/`, `%` (modulo), parentheses for grouping.

## Variables

Variables can be declared at the top level or inside element blocks:

```
var bar_empty = $sprite(spr_GUI_Stat_Bar_Empty) {
    slices = (1, 0, 4, 0)
}

@bar(hp_fill) {
    sprite_empty = bar_empty
}
```

## Data Bindings

Bindings reference runtime values from the game using the `*` prefix:

```
@bar(hp_fill) {
    value = *hp_value
    max = *hp_max
}

@slot(slot) {
    slot_index = *slot_index
}
```

Bound values are resolved at runtime from the UI link context.

Array indexing is also supported:

```
choices = *dropdown_choices
text = *names[index]
```

Plain arrays are treated as data, while proglang closures are executed and their return value is bound.

## Events

Event handlers use `on_* = @"namespace:script/path"` syntax:

```
@button(confirm) {
    text = "Confirm"
    on_select_release = @"phantasia:menu/confirm"
}
```

When an event fires, the handler receives a context containing:

- `element`: the UI element instance
- `element_name`: the element name from the `.ui` file
- `event`: the fired event name
- `data`: event payload, when provided by the element

## Repeat

The `repeat(count, var)` modifier creates multiple copies of an element. The loop variable is available in property expressions.

```
@slot(hotbar_slots) repeat(10, i) {
    inventory_name = "base"
    slot_index = i
}
```

This generates 10 slot elements named `hotbar_slots_0` through `hotbar_slots_9`, with `i` set to `0..9` for each.

### Repeat with Expressions

The loop variable can be used in math expressions:

```
@slot(inventory_slots) repeat(40, index) {
    inventory_name = "base"
    slot_index = index + 10
    position = (index % 10 * 16, floor(index / 10) * 16)
}
```

This creates a 10×4 grid of 40 inventory slots.

## Sprites

Sprites are referenced with the `$sprite()` function. Nine-slice configuration can be set inline:

```
var bar_empty = $sprite(spr_GUI_Stat_Bar_Empty) {
    slices = (1, 0, 4, 0)
}

@image(icon) {
    source = $sprite(spr_GUI_Stat_Icon_HP)
}
```

## Full Examples

### Hotbar

```
@area(hotbar_row) {
    position = ORIGIN_BOTTOM_CENTER + (8, 8)
    size = (160, 16)
    layout = LAYOUT_HORIZONTAL

    @slot(hotbar_slots) repeat(10, i) {
        inventory_name = "base"
        slot_index = i
    }
}
```

### Stat Bars

```
var bar_empty = $sprite(spr_GUI_Stat_Bar_Empty) {
    slices = (1, 0, 4, 0)
}

@area(hp_container) {
    position = ORIGIN_BOTTOM_RIGHT + (8, 36)
    size = (160, 7)

    @image(hp_icon) {
        position = ORIGIN_TOP_LEFT + (0, -1)
        source = $sprite(spr_GUI_Stat_Icon_HP)
    }

    @bar(hp_fill) {
        position = ORIGIN_TOP_LEFT + (7, 0)
        size = (153, 5)
        value = *hp_value
        max = *hp_max
        sprite_empty = bar_empty
        sprite_fill = $sprite(spr_GUI_Stat_Bar_HP) {
            slices = (1, 0, 4, 0)
        }
    }
}
```

## Functions

### `floor(n)`: number

Rounds down to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

---
