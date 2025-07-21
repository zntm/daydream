function render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __u_offset = shader_get_uniform(shd_Chunk, "u_offset");
    static __u_texture_size = shader_get_uniform(shd_Chunk, "u_texture_size");
    static __u_time = shader_get_uniform(shd_Chunk, "u_time");
    static __u_skew = shader_get_uniform(shd_Chunk, "u_skew");
    
    var _creature_data = global.creature_data;
    var _item_data = global.item_data;
    var _particle_data = global.particle_data;
    
    var _texture = global.carbasa_surface_texture[$ "item"];
    
    if (!surface_exists(_texture))
    {
        carbasa_repair_page("item");
        
        _texture = global.carbasa_surface_texture[$ "item"];
    }
    
    var _texel_width  = texture_get_texel_width(_texture);
    var _texel_height = texture_get_texel_height(_texture);
    
    var _animation_index = round(global.world_save_data.time * 8);
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        shader_set(shd_Chunk);
        shader_set_uniform_f(__u_texture_size, _texel_width, _texel_height);
        shader_set_uniform_f(__u_time, _animation_index);
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if !(_inst.boolean & CHUNK_BOOLEAN.GENERATED) || !(_inst.chunk_display & _bitmask) || (_inst.chunk_count[_z] <= 0) continue;
            
            var _xcenter = _inst.xcenter;
            var _ycenter = _inst.ycenter;
            
            var _light = instance_nearest(_xcenter, _ycenter, obj_Parent_Light);
            
            if (!instance_exists(_light)) || (rectangle_distance(_light.x, _light.y, _xcenter - (CHUNK_SIZE_DIMENSION / 2), _ycenter - (CHUNK_SIZE_DIMENSION / 2), _xcenter + (CHUNK_SIZE_DIMENSION / 2), _ycenter + (CHUNK_SIZE_DIMENSION / 2)) >= (CHUNK_SIZE_DIMENSION * 3)) continue;
            
            var _buffer = _inst.chunk_vertex_buffer[_z];
            
            if (!vertex_buffer_exists(_buffer))
            {
                _buffer = render_chunk(global.carbasa_surface_uv[$ "item"], _inst, _z);
            }
            
            if (_z == CHUNK_DEPTH_FOLIAGE_BACK)
            {
                shader_set_uniform_f_array(__u_skew, _inst.chunk_skew_back);
            }
            else if (_z == CHUNK_DEPTH_FOLIAGE_FRONT)
            {
                shader_set_uniform_f_array(__u_skew, _inst.chunk_skew_front);
            }
            
            vertex_submit(_buffer, pr_trianglelist, _texture);
        }
        
        shader_reset();
        
        if (_z == CHUNK_DEPTH_DEFAULT)
        {
            with (obj_Particle)
            {
                var _data = _particle_data[$ _id];
                
                var _sprite = _data.get_sprite();
                
                draw_sprite_ext(_sprite, 0, x, y, entity_scale, entity_scale, image_angle, image_blend, image_alpha * (_data.is_fade_out() ? timer_life / timer_life_max : 1));
            }
            
            with (obj_Item_Drop)
            {
                var _data = _item_data[$ item.get_id()];
                
                var _sprite = _data.get_sprite();
                var _index  = _data.get_inventory_index();
                
                var _xscale = 8 / attribute.get_collision_box_width();
                var _yscale = 8 / attribute.get_collision_box_height();
                
                draw_sprite_ext(_sprite, _index, x, y - (_data.get_sprite_yoffset() * _yscale), _xscale, _yscale, image_angle, image_blend, 1);
            }
            
            with (obj_Creature)
            {
                var _variant = id[$ "variant"];
                
                var _data = _creature_data[$ _id];
                
                var _xscale = entity_scale * sign(image_xscale);
                var _yscale = entity_scale;
                
                if (yvelocity == 0) && ((input_left) || (input_right))
                {
                    draw_sprite_ext(_data.get_sprite_moving(_variant), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    
                    var _emissive = _data.get_sprite_moving_emissive(_variant);
                    
                    if (_emissive != undefined)
                    {
                        draw_sprite_ext(_emissive, _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    }
                }
                else
                {
                    draw_sprite_ext(_data.get_sprite_idle(_variant), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    
                    var _emissive = _data.get_sprite_idle_emissive(_variant);
                    
                    if (_emissive != undefined)
                    {
                        draw_sprite_ext(_emissive, _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    }
                }
            }
            
            with (obj_Player)
            {
                if (yvelocity == 0) && ((input_left) || (input_right))
                {
                    render_attire(global.player_save_data.attire, (_animation_index * 2) % 8, x, y, entity_scale * sign(image_xscale), entity_scale);
                }
                else
                {
                	render_attire(global.player_save_data.attire, 0, x, y, entity_scale * sign(image_xscale), entity_scale);
                }
            }
        }
    }
    
    if (harvest_amount > 0)
    {
        render_harvest(_camera_x, _camera_y, _camera_width, _camera_height);
    }
    
    if (instance_exists(obj_Floating_Text))
    {
        draw_set_align(fa_center, fa_middle);
        
        with (obj_Floating_Text)
        {
            render_text(x, y, text, image_xscale, image_yscale, image_angle, image_blend, power(timer_life, 1 / 4));
        }
        
        draw_set_align(fa_left, fa_top);
    }
    
    render_lighting(_camera_x, _camera_y, _camera_width, _camera_height);
}