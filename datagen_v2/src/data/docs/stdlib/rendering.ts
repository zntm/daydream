import { Doc } from "../../../lib";

export const rendering = new Doc("Rendering")
    .function("render_rectangle", "x1, y1, x2, y2, outline", "void", "Draws a rectangle.", [["`x1`", "number", "Left"], ["`y1`", "number", "Top"], ["`x2`", "number", "Right"], ["`y2`", "number", "Bottom"], ["`outline`", "boolean", "Draw outline only (Optional)"]], "render_rectangle(10, 10, 100, 100, false);")
    .function("render_circle", "x, y, r, outline", "void", "Draws a circle.", [["`x`", "number", "Center X"], ["`y`", "number", "Center Y"], ["`r`", "number", "Radius"], ["`outline`", "boolean", "Draw outline only (Optional)"]], "render_circle(50, 50, 20, false);")
    .function("render_text", "text, x, y", "void", "Draws text.", [["`text`", "string", "Text to draw"], ["`x`", "number", "X position"], ["`y`", "number", "Y position"]], 'render_text("Hello", 10, 10);')
    .function("render_sprite", "sprite, x, y, frame", "void", "Draws a sprite.", [["`sprite`", "string", "Sprite name"], ["`x`", "number", "X position"], ["`y`", "number", "Y position"], ["`frame`", "number", "Frame index (Optional)"]], 'render_sprite("spr_Player", 10, 10, 0);')
    .toString();
