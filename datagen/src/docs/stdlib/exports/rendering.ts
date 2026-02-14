import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const RenderingDocs = new DocModule("Rendering", "", [
    new DocFunction("render_rectangle", "Draws a rectangle.", [
        { name: "x1", type: "number", description: "Left" },
        { name: "y1", type: "number", description: "Top" },
        { name: "x2", type: "number", description: "Right" },
        { name: "y2", type: "number", description: "Bottom" },
        { name: "outline", type: "boolean", description: "Draw outline only (Optional)" }
    ], "void"),
    new DocFunction("render_circle", "Draws a circle.", [
        { name: "x", type: "number", description: "Center X" },
        { name: "y", type: "number", description: "Center Y" },
        { name: "r", type: "number", description: "Radius" },
        { name: "outline", type: "boolean", description: "Draw outline only (Optional)" }
    ], "void"),
    new DocFunction("render_text", "Draws text.", [
        { name: "text", type: "string", description: "Text to draw" },
        { name: "x", type: "number", description: "X position" },
        { name: "y", type: "number", description: "Y position" }
    ], "void"),
    new DocFunction("render_sprite", "Draws a sprite.", [
        { name: "sprite", type: "string", description: "Sprite name" },
        { name: "x", type: "number", description: "X position" },
        { name: "y", type: "number", description: "Y position" },
        { name: "frame", type: "number", description: "Frame index (Optional)" }
    ], "void"),
]);

export default [
    new DatagenReturnData("rendering.md", RenderingDocs.toMarkdown())
];
