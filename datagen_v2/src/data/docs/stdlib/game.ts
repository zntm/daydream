import { Doc } from "../../../lib";

export const game = new Doc("Game API")
    .function("tile_get", "x, y, z", "Tile?", "Gets the tile ID at the specified position.", [["`x`", "number", "X position"], ["`y`", "number", "Y position"], ["`z`", "number", "Z position (layer)"]])
    .function("tile_place", "tile_id, x, y, z", "void", "Places a tile at the specified position.", [["`tile_id`", "any", "Tile ID or name"], ["`x`", "number", "X position"], ["`y`", "number", "Y position"], ["`z`", "number", "Z position (layer)"]])
    .function("spawn_particle", "particle, x, y", "void", "Spawns a particle at the specified position.", [["`particle`", "string", "Particle name"], ["`x`", "number", "X position in tiles"], ["`y`", "number", "Y position in tiles"]])
    .function("tag_get", "tag_name", "any", "Gets tag data.", [["`tag_name`", "string", "Name of the tag (without #)"]])
    .toString();
