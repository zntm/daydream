function chunk_clear(_inst)
{
    if (_inst.chunk_surface_display)
    {
        for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
        {
            var _vertex_buffer = _inst.chunk_vertex_buffer[_z];
            
            if (vertex_buffer_exists(_vertex_buffer))
            {
                _collect = true;
                
                vertex_delete_buffer(_vertex_buffer);
            }
        }
    }
    
    instance_destroy(_inst);
}