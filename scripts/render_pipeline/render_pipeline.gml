function render_pipeline()
{
    static __u_offset = shader_get_uniform(shd_Chunk, "u_offset");
    
    var _texture = global.carbasa_surface_texture[$ "item"];
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        shader_set(shd_Chunk);
        
        with (obj_Chunk)
        {
            if (!is_in_view) || ((chunk_display & _bitmask) == 0) continue;
            
            if (!vertex_buffer_exists(chunk_vertex_buffer[_z]))
            {
                render_chunk(global.carbasa_surface_uv[$ "item"], id, _z);
            }
            
            var _buffer = chunk_vertex_buffer[_z];
            
            if (vertex_buffer_exists(_buffer))
            {
                shader_set_uniform_f(__u_offset, x, y);
                
                vertex_submit(_buffer, pr_trianglelist, _texture);
            }
        }
        
        shader_reset();
    }
}