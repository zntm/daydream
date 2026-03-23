/// @function tile_get(_x, _y, _z)
/// @desc Get tile at specified position
/// @returns {Struct.Tile} Tile at position or TILE_EMPTY
function tile_get(_x, _y, _z, _world_height = global.world_data[$ global.current_world.dimension].get_world_height())
{
    if (_y < 0) || (_y >= _world_height)
    {
        return TILE_EMPTY;
    }
    
    var _chunk = chunk_map_get_by_tile(_x, _y);
    
    if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOL.GENERATED)
    {
        return tile_predict(_x, _y, _z);
    }
    
    return _chunk.chunk[tile_index_xyz(_x, _y, _z)];
}
