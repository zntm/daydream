function tile_get(_x, _y, _z)
{
    if (_y < 0) || (_y >= global.world_data[$ global.world_save_data.dimension].get_world_height())
    {
        return TILE_EMPTY;
    }
    
    var _inst = chunk_map_get_by_tile(_x, _y);
    
    if (!instance_exists(_inst))
    {
        return tile_predict(_x, _y, _z);
    }
    
    return _inst.chunk[tile_index_xyz(_x, _y, _z)];
}