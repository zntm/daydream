# Rendering Functions

These functions allow you to draw shapes, text, and sprites to the screen.
They are typically used within a draw context or event.

## Shapes

### `render_rectangle(x1, y1, x2, y2, outline)`

Draws a rectangle defined by the top-left (x1, y1) and bottom-right (x2, y2) coordinates.

-   `x1`: The x coordinate of the left side.
-   `y1`: The y coordinate of the top side.
-   `x2`: The x coordinate of the right side.
-   `y2`: The y coordinate of the bottom side.
-   `outline` (optional): If true, draws only the outline. Default is false (filled).

```javascript
render_rectangle(10, 10, 100, 50, false);
```

### `render_circle(x, y, radius, outline)`

Draws a circle at (x, y) with the specified radius.

-   `x`: The x coordinate of the center.
-   `y`: The y coordinate of the center.
-   `radius`: The radius of the circle.
-   `outline` (optional): If true, draws only the outline. Default is false (filled).

```javascript
render_circle(50, 50, 20, true);
```

## Text

### `render_text(text, x, y)`

Draws a string of text at the specified position.

-   `text`: The string to draw.
-   `x`: The x coordinate.
-   `y`: The y coordinate.

```javascript
render_text("Hello World", 100, 100);
```

## Sprites

### `render_sprite(sprite_name, x, y, frame)`

Draws a sprite asset.

-   `sprite_name`: The name of the sprite asset (as a string).
-   `x`: The x coordinate.
-   `y`: The y coordinate.
-   `frame` (optional): The sub-image index to draw. Default is 0.

```javascript
render_sprite("spr_player_idle", 200, 200, 0);
```
