function render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __u_offset = shader_get_uniform(shd_Chunk, "u_offset");
    static __u_texture_size = shader_get_uniform(shd_Chunk, "u_texture_size");
    static __u_time = shader_get_uniform(shd_Chunk, "u_time");
    static __u_skew = shader_get_uniform(shd_Chunk, "u_skew");
    static __u_wave = shader_get_uniform(shd_Chunk, "u_wave");
    static __u_texel_width = shader_get_uniform(shd_Chunk, "u_texel_width");
    static __u_fade = shader_get_uniform(shd_Chunk, "u_fade");
    
    var _creature_data = global.creature_data;
    var _item_data = global.item_data;
    var _particle_data = global.particle_data;
    var _projectile_data = global.projectile_data;
    
    atla_repair("item");
    
    var _page = global.___atla_page[$ "item"];
    var _position = global.___atla_page_position[$ "item"];
    
    var _texture = global.___atla_surface_texture[$ "item"];
    
    var _surface_size = global.___atla_surface_size[$ "item"];
    
    var _surface_width  = (_surface_size >> 0)  & 0xffff;
    var _surface_height = (_surface_size >> 16) & 0xffff;
    
    var _texel_width  = 1 / _surface_width;
    var _texel_height = 1 / _surface_height;
    
    var _animation_index = round(global.world_save_data.time * 8);
    
    var _sprite_asset = global.sprite_asset;
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        shader_set(shd_Chunk);
        shader_set_uniform_f(__u_time, _animation_index);
        shader_set_uniform_f(__u_texel_width, _texel_width);
        
        // Ensure blending is enabled for fade effect
        gpu_set_blendenable(true);
        gpu_set_blendmode(bm_normal);
        
        // properties
        if (array_length(global.chunk_pool.fading_chunks) > 0)
        {
             // dbg_log($"Fading chunks: {array_length(global.chunk_pool.fading_chunks)}");
        }
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];
            
            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) || !(_chunk.boolean & CHUNK_BOOLEAN.TILE_PROCESSED) || !(_chunk.chunk_display & _bitmask) || (_chunk.chunk_count[_z] <= 0) continue;
            
            var _buffer = _chunk.chunk_vertex_buffer[_z];
            
            if (!vertex_buffer_exists(_buffer))
            {
                _buffer = render_chunk(_page, _position, _texel_width, _texel_height, _chunk, _z);
            }
            
            if (vertex_get_number(_buffer) <= 0) continue;
            
            // Set fade uniform
            var _t = _chunk.timer_fade;
            shader_set_uniform_f(__u_fade, _t * _t * (3 - 2 * _t)); // Smoothstep
            
            var _chunk_count_arr = _chunk.chunk_count;
            
            if ((_z == CHUNK_DEPTH_FOLIAGE_BACK) || (_z == CHUNK_DEPTH_FOLIAGE_FRONT)) && ((_chunk_count_arr[CHUNK_DEPTH_FOLIAGE_BACK] > 0) || (_chunk_count_arr[CHUNK_DEPTH_FOLIAGE_FRONT] > 0))
            {
                shader_set_uniform_f_array(__u_skew, _chunk.chunk_skew);
            }
            else if (_z == CHUNK_DEPTH_LIQUID) && (_chunk_count_arr[CHUNK_DEPTH_LIQUID] > 0)
            {
                shader_set_uniform_f_array(__u_wave, _chunk.chunk_wave);
            }
            
            vertex_submit(_buffer, pr_trianglelist, _texture);
        }
        
        shader_reset();
        
        if (_z == CHUNK_DEPTH_DEFAULT) && (!IS_DEVELOPER_MODE || global.dbg_settings.display_instances)
        {
            with (obj_Item_Drop)
            {
                var _data = _item_data[$ item.get_id()];
                
                var _sprite = _sprite_asset[$ _data.get_sprite()];
                var _index  = _data.get_inventory_index();
                
                var _xscale = 8 / attribute.get_collision_box_width();
                var _yscale = 8 / attribute.get_collision_box_height();
                
                draw_sprite_ext(_sprite.get_sprite(), _index, x, y - (_sprite.get_yoffset() * _yscale), _xscale, _yscale, image_angle, image_blend, 1);
            }
            
            with (obj_Falling_Tile)
            {
                var _data = _item_data[$ tile_id];
                
                if (_data != undefined)
                {
                    var _sprite = _sprite_asset[$ _data.get_sprite()];
                    
                    if (_sprite != undefined)
                    {
                        draw_sprite_ext(_sprite.get_sprite(), tile_index, x, y, entity_xscale, entity_yscale, 0, c_white, 1);
                    }
                }
            }
            
            with (obj_Creature)
            {
                var _variant = id[$ "variant"];
                
                var _data = _creature_data[$ _id];
                
                var _xscale = entity_xscale * sign(image_xscale);
                var _yscale = entity_yscale * sign(image_yscale);
                
                if (physics_body.vel_y == 0) && (input_state.move_x != 0)
                {
                    draw_sprite_ext(_sprite_asset[$ _data.get_sprite_moving(_variant)].get_sprite(), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    
                    var _emissive = _data.get_sprite_moving_emissive(_variant);
                    
                    if (_emissive != undefined)
                    {
                        draw_sprite_ext(_sprite_asset[$ _emissive].get_sprite(), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    }
                }
                else
                {
                    draw_sprite_ext(_sprite_asset[$ _data.get_sprite_idle(_variant)].get_sprite(), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    
                    var _emissive = _data.get_sprite_idle_emissive(_variant);
                    
                    if (_emissive != undefined)
                    {
                        draw_sprite_ext(_sprite_asset[$ _emissive].get_sprite(), _animation_index, x, y, _xscale, _yscale, image_angle, c_white, 1);
                    }
                }
            }
            
            // Draw pooled light sprites
            for (var i = 0; i < chunk_in_view_length; ++i)
            {
                var _chunk = chunk_in_view[i];
                if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
                
                var _lights = _chunk.chunk_lights;
                var _length = array_length(_lights);
                
                for (var j = 0; j < _length; ++j)
                {
                    var _l = _lights[j];
                    
                    // Simple culling
                    if (_l.x < _camera_x - TILE_SIZE) || (_l.x > _camera_x + _camera_width + TILE_SIZE) || 
                       (_l.y < _camera_y - TILE_SIZE) || (_l.y > _camera_y + _camera_height + TILE_SIZE) continue;
                    
                    var _subimg = _l.image_index;
                     
                     // Simple animation if sprite has multiple frames
                    if (sprite_get_number(_l.sprite_index) > 1) {
                         _subimg += _animation_index;
                    }
                    
                    draw_sprite_ext(_l.sprite_index, _subimg, _l.x, _l.y, 1, 1, _l.image_angle, _l.image_blend, 1);
                }
            }
            
            with (obj_Player)
            {
                var _xscale = entity_xscale * sign(image_xscale);
                var _yscale = entity_yscale * sign(image_yscale);
                
                if (physics_body.vel_y == 0) && (input_state.move_x != 0)
                {
                    var _index_body = (_animation_index * 2) % 8;
                    var _index_arm = ((timer_attack > 0) ? round(lerp(13, 8, timer_attack / 0.3)) : _index_body);
                    
                    if (attire != undefined) render_attire(attire, _index_body, x, y, _xscale, _yscale, false, _index_arm, inst_item);
                }
                else
                {
                    var _index_arm = ((timer_attack > 0) ? round(lerp(13, 8, timer_attack / 0.3)) : 0);
                    
                    if (attire != undefined) render_attire(attire, 0, x, y, _xscale, _yscale, false, _index_arm, inst_item);
                }
            }
            
            with (obj_Client)
            {
                var _xscale = entity_xscale * sign(image_xscale);
                var _yscale = entity_yscale * sign(image_yscale);
                
                if (variable_instance_exists(self, "input_state") && input_state.move_x != 0)
                {
                    var _index_body = (_animation_index * 2) % 8;
                    var _index_arm = ((timer_attack > 0) ? round(lerp(13, 8, timer_attack / 0.3)) : _index_body);
                    
                    if (attire != undefined) render_attire(attire, _index_body, x, y, _xscale, _yscale, false, _index_arm, inst_item);
                }
                else
                {
                    var _index_arm = ((timer_attack > 0) ? round(lerp(13, 8, timer_attack / 0.3)) : 0);
                    
                    if (attire != undefined) render_attire(attire, 0, x, y, _xscale, _yscale, false, _index_arm, inst_item);
                }
            }
            
            with (obj_Tool)
            {
                if (variable_instance_exists(id, "hold_type") && hold_type == ITEM_HOLD_TYPE.WHIP)
                {
                    var _segments = variable_instance_exists(id, "whip_segments") ? whip_segments : undefined;
                    var _sprite = sprite_index;
                    
                    if (_segments != undefined)
                    {
                        var _frame_hold = _segments.hold;
                        
                        draw_sprite_ext(_sprite, _frame_hold, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
                        
                        if (instance_exists(inst_owner))
                        {
                            var _x_start = x;
                            var _y_start = y;
                            var _aim_angle = inst_owner.input_state.aim_angle;
                            
                            // Animation Progress
                            var _timer = inst_owner.timer_attack;
                            var _duration = 0.3; // Matches control_player attack timer
                            var _progress = clamp((_duration - _timer) / _duration, 0, 1);
                            
                            // Length calculation (Extend and Retract)
                            var _max_range = 64; 
                             // Use sine wave for smooth extend-retract
                            var _extension = sin(_progress * pi); 
                            
                            var _len = _max_range * _extension;
                            
                            var _x_end = _x_start + lengthdir_x(_len, _aim_angle);
                            var _y_end = _y_start + lengthdir_y(_len, _aim_angle);
                            
                            // Curve Control Point (P1)
                            var _mid_x = (_x_start + _x_end) / 2;
                            var _mid_y = (_y_start + _y_end) / 2;
                            
                            // Wave/Snap Effect: Offset P1 perpendicular to aim
                            var _wave_mag = 32 * sin(_progress * pi);
                            var _wave_dir = (_progress < 0.5) ? 1 : -1;
                            
                            var _p1_x = _mid_x + lengthdir_x(_wave_mag * _wave_dir, _aim_angle + 90);
                            var _p1_y = _mid_y + lengthdir_y(_wave_mag * _wave_dir, _aim_angle + 90);
                            
                            var _dist = point_distance(_x_start, _y_start, _x_end, _y_end);
                            
                            if (_dist > 4)
                            {
                                var _segment_count = 8;
                                var _last_x = _x_start;
                                var _last_y = _y_start;
                                
                                for (var i = 1; i <= _segment_count; ++i)
                                {
                                    var _t = i / _segment_count;
                                    
                                    // Quadratic Bezier Formula
                                    // B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
                                    var _one_minus_t = 1 - _t;
                                    var _bx = (_one_minus_t * _one_minus_t * _x_start) + (2 * _one_minus_t * _t * _p1_x) + (_t * _t * _x_end);
                                    var _by = (_one_minus_t * _one_minus_t * _y_start) + (2 * _one_minus_t * _t * _p1_y) + (_t * _t * _y_end);
                                    
                                    // Angle from last segment
                                    var _seg_angle = point_direction(_last_x, _last_y, _bx, _by);
                                    
                                    // Determine sprite frame
                                    var _frame = (i == _segment_count) ? _segments.tip : smart_value(_segments.mid);
                                    
                                    draw_sprite_ext(_sprite, _frame, _bx, _by, 1, 1, _seg_angle, c_white, 1);
                                    
                                    _last_x = _bx;
                                    _last_y = _by;
                                }
                            }
                        }
                    }
                }
            }
            
            gpu_set_blendmode(bm_add);
            
            with (obj_Projectile)
            {
                var _data = _projectile_data[$ _id];
                
                if (!_data.is_additive()) continue;
                
                var _sprite = _sprite_asset[$ _data.get_sprite()];
                
                var _index = 0;
                
                if (_data.has_stretch_animation())
                {
                    _index = floor(_sprite.get_length() * (1 - (timer_life / timer_life_max)));
                }
                
                var _xscale = entity_xscale * sign(image_xscale);
                var _yscale = entity_yscale * sign(image_yscale);
                
                draw_sprite_ext(_sprite.get_sprite(), _index, x + (_xscale * (_sprite.get_xoffset() - (attribute.get_collision_box_width() / 2))), y + (_yscale * (_sprite.get_yoffset() - attribute.get_collision_box_height())), _xscale, _yscale, image_angle, image_blend, image_alpha * (_data.is_fade_out() ? timer_life / timer_life_max : 1));
            }
            
            gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
            
            with (obj_Projectile)
            {
                var _data = _projectile_data[$ _id];
                
                if (_data.is_additive()) continue;
                
                var _sprite = _sprite_asset[$ _data.get_sprite()];
                
                var _index = 0;
                
                if (_data.has_stretch_animation())
                {
                    _index = floor(_sprite.get_length() * (1 - (timer_life / timer_life_max)));
                }
                
                var _xscale = entity_xscale * sign(image_xscale);
                var _yscale = entity_yscale * sign(image_yscale);
                
                draw_sprite_ext(_sprite.get_sprite(), _index, x + (_xscale * (_sprite.get_xoffset() - (attribute.get_collision_box_width() / 2))), y + (_yscale * (_sprite.get_yoffset() - attribute.get_collision_box_height())), _xscale, _yscale, image_angle, image_blend, image_alpha * (_data.is_fade_out() ? timer_life / timer_life_max : 1));
            }
        }
    }
    
    render_harvest(_camera_x, _camera_y, _camera_width, _camera_height);
    
    render_build_preview();
    
    render_particles_batch();
    
    var _floating_text_active = global.floating_text_active;
    var _floating_text_active_length = array_length(_floating_text_active);
    
    if (_floating_text_active_length > 0)
    {
        draw_set_align(fa_center, fa_middle);
        
        for (var i = 0; i < _floating_text_active_length; ++i)
        {
            var _inst = _floating_text_active[i];
            
            with (_inst)
            {
                render_text(x, y, text, image_xscale, image_yscale, image_angle, image_blend, power(timer_life, 1 / 4));
            }
        }
        
        draw_set_align(fa_left, fa_top);
    }
    
    if (!IS_DEVELOPER_MODE || global.dbg_settings.enable_lighting)
    {
        render_lighting(_camera_x, _camera_y, _camera_width, _camera_height);
    }
    
    var _render_state = global.render_state;
    
    var _all_chunks = chunk_map_get_all();
    var _all_chunks_length = array_length(_all_chunks);
    
    for (var c = 0; c < _all_chunks_length; ++c)
    {
        var _chunk = _all_chunks[c];
        var _chunk_render_state = _chunk.chunk_render_state;
        var _length = array_length(_chunk_render_state);
        
        for (var i = 0; i < _length; ++i)
        {
            var _ = _chunk_render_state[i];
            
            var _x = _.x;
            var _y = _.y;
            var _z = _.z;
            
            var _data = _.data;
            var _data_length = array_length(_data);
            
            for (var j = 0; j < _data_length; ++j)
            {
                _render_state[$ _data[j].id](_x, _y, _z);
            }
        }
    }
    
    if (IS_DEVELOPER_MODE)
    {
        var _dbg_settings = global.dbg_settings;
        
        if (_dbg_settings[$ "display_chunk_boundary"])
        {
            for (var c = 0; c < _all_chunks_length; ++c)
            {
                var _chunk = _all_chunks[c];
                
                var _x1 = _chunk.x - (TILE_SIZE / 2);
                var _y1 = _chunk.y - (TILE_SIZE / 2);
                var _x2 = _x1 - 1 + CHUNK_SIZE_DIMENSION;
                var _y2 = _y1 - 1 + CHUNK_SIZE_DIMENSION;
                
                draw_rectangle_colour(_x1, _y1, _x2, _y2, c_red, c_yellow, c_purple, c_blue, true);
            }
        }
        
        if (_dbg_settings[$ "display_chunk_information"])
        {
            for (var c = 0; c < _all_chunks_length; ++c)
            {
                var _chunk = _all_chunks[c];
                
                draw_text_ext_transformed(
                    _chunk.x,
                    _chunk.y,
                    $"X/Y: ({_chunk.x}, {_chunk.y}) ({round(_chunk.x / TILE_SIZE)}, {round(_chunk.y / TILE_SIZE)}), ({round(_chunk.x / CHUNK_SIZE_DIMENSION)}, {round(_chunk.y / CHUNK_SIZE_DIMENSION)})",
                    0,
                    0xffff,
                    0.25,
                    0.25,
                    0
                );
            }
        }
    }
}
