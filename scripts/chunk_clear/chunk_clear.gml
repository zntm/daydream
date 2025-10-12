function chunk_clear(_inst)
{
    if (_inst.chunk_display)
    {
        var _chunk = _inst.chunk;
        var _chunk_audio_emitter = _inst.chunk_audio_emitter;
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
        /*
        for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH; ++i)
        {
            var _tile = _chunk[i];
            
            if (_tile != TILE_EMPTY)
            {
                delete _tile;
            }
        }
        */
        for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE; ++i)
        {
            var _tile = _chunk_audio_emitter[i];
            
            if (audio_emitter_exists(_tile))
            {
                audio_emitter_free(_tile);
            }
        }
    }
    
    instance_destroy(_inst);
}