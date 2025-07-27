function tile_placement_condition(_x, _y, _z, _item)
{
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _item.get_id()];
    
    var _requirements = _data.get_placement_condition();
    
    if (_requirements != undefined)
    {
        return tile_met_custom_placement_condition(_x, _y, _z, _requirements);
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