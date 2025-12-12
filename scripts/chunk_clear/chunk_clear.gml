function chunk_clear(_inst)
{
    if (_inst.chunk_display)
    {
        var _chunk = _inst.chunk;
        var _chunk_vertex_buffer = _inst.chunk_vertex_buffer;
        
        for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
        {
            var _vertex_buffer = _chunk_vertex_buffer[_z];
            
            if (vertex_buffer_exists(_vertex_buffer))
            {
                vertex_delete_buffer(_vertex_buffer);
            }
        }
        
        file_save_world_chunk(global.world_save_data, id);
    }
    
    instance_destroy(_inst);
}
