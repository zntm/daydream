function tile_placement_condition(_x, _y, _z, _item)
{
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _item.get_id()];
    
    var _requirements = _data.get_placement_condition();
    
    if (_requirements != undefined)
    {
        return tile_met_custom_placement_condition(_x, _y, _z, _requirements, _item_data, _item.get_id());
    }
    
    if (_z == CHUNK_DEPTH_DEFAULT)
    {
        if
        (tile_get(_x, _y, CHUNK_DEPTH_WALL) == TILE_EMPTY) &&
        (tile_get(_x - 1, _y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
        (tile_get(_x, _y - 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
        (tile_get(_x + 1, _y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
        (tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY)
        {
            return false;
        }
    }
    else if (_z == CHUNK_DEPTH_WALL)
    {
        if
        (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
        (tile_get(_x - 1, _y, CHUNK_DEPTH_WALL) == TILE_EMPTY) &&
        (tile_get(_x, _y - 1, CHUNK_DEPTH_WALL) == TILE_EMPTY) &&
        (tile_get(_x + 1, _y, CHUNK_DEPTH_WALL) == TILE_EMPTY) &&
        (tile_get(_x, _y + 1, CHUNK_DEPTH_WALL) == TILE_EMPTY)
        {
            return false;
        }
    }
    else if (_z == CHUNK_DEPTH_FOLIAGE_BACK) || (_z == CHUNK_DEPTH_FOLIAGE_FRONT)
    {
        if
        (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) != TILE_EMPTY) ||
        (tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY)
        {
            return false;
        }
    }
    
    return true;
}

function tile_placement_is_valid(_x, _y, _z, _item)
{
    // Basic check for empty space and initial placement condition
    if (tile_get(_x, _y, _z) != TILE_EMPTY) return false;
    if (!tile_placement_condition(_x, _y, _z, _item)) return false;
    
    // Simulate placement to check if it breaks any surrounding tiles
    var _chunk = chunk_map_get_by_tile(_x, _y);
    if (_chunk == undefined) return true; // Fail-safe: if chunk isn't loaded, we can't fully validate neighbors
    
    var _index = tile_index_xyz(_x, _y, _z);
    var _tile_before = _chunk.chunk[_index];
    
    // Create a temporary tile for simulation
    var _new_tile = new Tile(_item.get_id());
    
    // Patch the chunk data
    _chunk.chunk[@ _index] = _new_tile;
    
    var _is_stable = true;
    
    // Check neighbors in a 3x3 area across all layers
    // Note: We only check tiles that actually exist and have placement requirements
    for (var _nx = _x - 1; _nx <= _x + 1; ++_nx)
    {
        for (var _ny = _y - 1; _ny <= _y + 1; ++_ny)
        {
            for (var _nz = 0; _nz < CHUNK_DEPTH; ++_nz)
            {
                // Skip the tile we just placed
                if (_nx == _x && _ny == _y && _nz == _z) continue;
                
                var _neighbor = tile_get(_nx, _ny, _nz);
                
                // If neighbor exists, check if it's still valid in the new environment
                if (_neighbor != TILE_EMPTY)
                {
                    // Tiles meet their own placement requirements
                    // Note: Tile objects work here because tile_placement_condition only uses .get_id()
                    if (!tile_placement_condition(_nx, _ny, _nz, _neighbor))
                    {
                        _is_stable = false;
                        break;
                    }
                }
            }
            if (!_is_stable) break;
        }
        if (!_is_stable) break;
    }
    
    // Revert the chunk data
    _chunk.chunk[@ _index] = _tile_before;
    
    // Cleanup temporary tile
    delete _new_tile;
    
    return _is_stable;
}
