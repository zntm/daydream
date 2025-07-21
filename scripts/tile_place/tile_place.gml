function tile_place(_x, _y, _z, _tile)
{
    if (_y < 0) || (_y >= global.world_data[$ global.world_save_data.dimension].get_world_height())
    {
        return TILE_EMPTY;
    }
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst))
    {
        _inst = instance_create_layer(_chunk_x, _chunk_y, "Instances", obj_Chunk);
        
        control_update_chunk_in_view();
    }
    
    var _index = tile_index(_x, _y, _z);
    
    if (_tile != TILE_EMPTY)
    {
        _inst.chunk_display |= 1 << _z;
        
        ++_inst.chunk_count[@ _z];
    }
    else if (_inst.chunk[_index] != TILE_EMPTY) && (--_inst.chunk_count[_z] <= 0)
    {
        _inst.chunk_display ^= 1 << _z;
    }
    
    _inst.chunk[@ _index] = _tile;
    
    var _vertex_buffer = _inst.chunk_vertex_buffer[_z];
    
    if (vertex_buffer_exists(_vertex_buffer))
    {
        vertex_delete_buffer(_vertex_buffer);
    }
}