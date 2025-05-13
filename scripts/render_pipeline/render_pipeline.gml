function render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __u_offset = shader_get_uniform(shd_Chunk, "u_offset");
    static __u_texture_size = shader_get_uniform(shd_Chunk, "u_textureSize");
    static __u_time = shader_get_uniform(shd_Chunk, "u_time");
    static __u_skew = shader_get_uniform(shd_Chunk, "u_skew");
    
    var _texture = global.carbasa_surface_texture[$ "item"];
    
    var _texel_width  = texture_get_texel_width(_texture);
    var _texel_height = texture_get_texel_height(_texture);
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        shader_set(shd_Chunk);
        shader_set_uniform_f(__u_texture_size, _texel_width, _texel_height);
        shader_set_uniform_f(__u_time, round(global.world.time / 4));
        
        var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
        var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
        
        for (var i = -_a; i < _a; ++i)
        {
            for (var j = -_b; j < _b; ++j)
            {
                var _x = (round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (i * CHUNK_SIZE_DIMENSION);
                var _y = (round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (j * CHUNK_SIZE_DIMENSION);
                
                var _inst = instance_position(_x, _y, obj_Chunk);
                
                if (!instance_exists(_inst)) || (!_inst.is_generated) || ((_inst.chunk_display & _bitmask) == 0) || (_inst.chunk_count[_z] <= 0) continue;
                
                var _buffer = _inst.chunk_vertex_buffer[_z];
                
                if (!vertex_buffer_exists(_buffer))
                {
                    _buffer = render_chunk(global.carbasa_surface_uv[$ "item"], _inst, _z);
                }
                
                if (_bitmask & ((1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT)))
                {
                    shader_set_uniform_f_array(__u_skew, _inst.chunk_skew);
                }
                
                vertex_submit(_buffer, pr_trianglelist, _texture);
            }
        }
        
        shader_reset();
    }
    
    with (obj_Chunk)
    {
        if (!chunk_display) continue;
        
        draw_rectangle(
            x - (TILE_SIZE / 2),
            y - (TILE_SIZE / 2),
            x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1,
            y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1,
            true
        );
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            draw_text(
                x - (TILE_SIZE / 2) + (i * 16),
                y - (TILE_SIZE / 2),
                vertex_buffer_exists(chunk_vertex_buffer[i])
            );
        }
    }
}