import { DatagenReturnData } from "../../../lib";
import { DocModule } from "../../lib/DocModule";
import { DocFunction } from "../../lib/DocFunction";

const GameDocs = new DocModule("Game API", "", [
    new DocFunction("tile_get", "Gets the tile ID at the specified position.", [{ name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }, { name: "z", type: "number", description: "Z position (layer)" }], "Tile?"),
    new DocFunction("tile_place", "Places a tile at the specified position.", [{ name: "tile_id", type: "any", description: "Tile ID or name" }, { name: "x", type: "number", description: "X position" }, { name: "y", type: "number", description: "Y position" }, { name: "z", type: "number", description: "Z position (layer)" }], "void"),
    new DocFunction("spawn_particle", "Spawns a particle at the specified position.", [{ name: "particle", type: "string", description: "Particle name" }, { name: "x", type: "number", description: "X position in tiles" }, { name: "y", type: "number", description: "Y position in tiles" }], "void"),
    new DocFunction("tag_get", "Gets tag data.", [{ name: "tag_name", type: "string", description: "Name of the tag (without #)" }], "any"),
]);

export default [
    new DatagenReturnData("game.md", GameDocs.toMarkdown())
];
