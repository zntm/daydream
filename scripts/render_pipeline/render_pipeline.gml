function render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __u_offset = shader_get_uniform(shd_Chunk, "u_offset");
    static __u_texture_size = shader_get_uniform(shd_Chunk, "u_texture_size");
    static __u_time = shader_get_uniform(shd_Chunk, "u_time");
    static __u_skew = shader_get_uniform(shd_Chunk, "u_skew");
    
    var _item_data = global.item_data;
    
    var _texture = global.carbasa_surface_texture[$ "item"];
    
    if (!surface_exists(_texture))
    {
        carbasa_repair_page("item");
        
        _texture = global.carbasa_surface_texture[$ "item"];
    }
    
    var _texel_width  = texture_get_texel_width(_texture);
    var _texel_height = texture_get_texel_height(_texture);
    
    var _animation_index = round(global.world_save_data.time * 8);
    
    var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    
    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        shader_set(shd_Chunk);
        shader_set_uniform_f(__u_texture_size, _texel_width, _texel_height);
        shader_set_uniform_f(__u_time, _animation_index);
        
        for (var i = -_a; i < _a; ++i)
        {
            var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);
            
            for (var j = -_b; j < _b; ++j)
            {
                var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);
                
                var _inst = instance_position(_x, _y, obj_Chunk);
                
                if (!instance_exists(_inst)) || (!_inst.is_generated) || !(_inst.chunk_display & _bitmask) || (_inst.chunk_count[_z] <= 0) continue;
                
                var _buffer = _inst.chunk_vertex_buffer[_z];
                
                if (!vertex_buffer_exists(_buffer))
                {
                    _buffer = render_chunk(global.carbasa_surface_uv[$ "item"], _inst, _z);
                }
                
                if (_bitmask & (1 << CHUNK_DEPTH_FOLIAGE_BACK))
                {
                    shader_set_uniform_f_array(__u_skew, _inst.chunk_skew_back);
                }
                else if (_bitmask & (1 << CHUNK_DEPTH_FOLIAGE_FRONT))
                {
                    shader_set_uniform_f_array(__u_skew, _inst.chunk_skew_front);
                }
                
                vertex_submit(_buffer, pr_trianglelist, _texture);
            }
        }
        
        shader_reset();
        
        if (_z == CHUNK_DEPTH_DEFAULT)
        {
            with (obj_Creature)
            {
                draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
            }
            
            with (obj_Player)
            {
                draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
            }
            
            with (obj_Item_Drop)
            {
                var _data = _item_data[$ item.get_id()];
                
                var _sprite = _data.get_sprite();
                var _index  = _data.get_inventory_index();
                
                var _xscale = 8 / attribute.get_collision_box_width();
                var _yscale = 8 / attribute.get_collision_box_height();
                
                draw_sprite_ext(_sprite, _index, x, y - (_data.get_sprite_yoffset() * _yscale), _xscale, _yscale, image_angle, c_white, 1);
            }
        }
    }
    
    draw_set_align(fa_center, fa_middle);
    
    with (obj_Floating_Text)
    {
        render_text(x, y, text, 0, 255, image_xscale, image_yscale, image_angle, image_blend, power(timer_life, 1 / 4));
    }
    
    draw_set_align(fa_left, fa_top);
}