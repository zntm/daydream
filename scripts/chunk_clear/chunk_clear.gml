function chunk_clear(_inst)
{
    if (_inst.chunk_display)
    {
        for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
        {
            var _vertex_buffer = _inst.chunk_vertex_buffer[_z];
            
            if (vertex_buffer_exists(_vertex_buffer))
            {
                vertex_delete_buffer(_vertex_buffer);
            }
        }
        
        file_save_world_chunk(global.world_save_data, id);
        
        for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH; ++i)
        {
            var _tile = _inst.chunk[i];
            
            if (_tile != TILE_EMPTY)
            {
                delete _tile;
            }
        }
    }
    
    instance_destroy(_inst);
}