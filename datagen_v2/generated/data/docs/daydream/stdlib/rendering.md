# Rendering

### `render_rectangle(x1, y1, x2, y2, outline)`: void

Draws a rectangle.

**Arguments:**
| Name      | Type    | Description                  |
| --------- | ------- | ---------------------------- |
| `x1`      | number  | Left                         |
| `y1`      | number  | Top                          |
| `x2`      | number  | Right                        |
| `y2`      | number  | Bottom                       |
| `outline` | boolean | Draw outline only (Optional) |

**Returns:** void

```javascript
render_rectangle(10, 10, 100, 100, false);
```

---

### `render_circle(x, y, r, outline)`: void

Draws a circle.

**Arguments:**
| Name      | Type    | Description                  |
| --------- | ------- | ---------------------------- |
| `x`       | number  | Center X                     |
| `y`       | number  | Center Y                     |
| `r`       | number  | Radius                       |
| `outline` | boolean | Draw outline only (Optional) |

**Returns:** void

```javascript
render_circle(50, 50, 20, false);
```

---

### `render_text(text, x, y)`: void

Draws text.

**Arguments:**
| Name   | Type   | Description  |
| ------ | ------ | ------------ |
| `text` | string | Text to draw |
| `x`    | number | X position   |
| `y`    | number | Y position   |

**Returns:** void

```javascript
render_text("Hello", 10, 10);
```

---

### `render_sprite(sprite, x, y, frame)`: void

Draws a sprite.

**Arguments:**
| Name     | Type   | Description            |
| -------- | ------ | ---------------------- |
| `sprite` | string | Sprite name            |
| `x`      | number | X position             |
| `y`      | number | Y position             |
| `frame`  | number | Frame index (Optional) |

**Returns:** void

```javascript
render_sprite("spr_Player", 10, 10, 0);
```

---
