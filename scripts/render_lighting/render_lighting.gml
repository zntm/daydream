#macro SURFACE_LIGHTING_SIZE (1 / 16)

#macro RENDER_LIGHTING_RESIZE 16
#macro RENDER_LIGHTING_PADDING 16

function render_lighting(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _surface_lighting_width  = ceil(_camera_width  / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    var _surface_lighting_height = ceil(_camera_height / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    
    var _surface_x = round(_camera_x / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    var _surface_y = round(_camera_y / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    
    // Check if any chunks need lighting refresh (new/loaded chunks)
    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _chunk = chunk_in_view[i];
        
        if (_chunk != undefined) && (_chunk.boolean & CHUNK_BOOLEAN.GENERATED) && (_chunk.boolean & CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH)
        {
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
            break;
        }
    }
    
    if (_surface_x != obj_Game_Control.surface_lighting_x) || (_surface_y != obj_Game_Control.surface_lighting_y)
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.LIGHTING)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        obj_Game_Control.surface_lighting_x = _surface_x;
        obj_Game_Control.surface_lighting_y = _surface_y;
        
        // Cache padding offset once
        var _padding_offset = RENDER_LIGHTING_PADDING / 2;
        
        // Create/update lighting surfaces ONLY when needed
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];
            
            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            // Check if surface needs updating
            var _needs_update = false;
            
            // Create surface if it doesn't exist
            if (!surface_exists(_chunk.surface_lighting))
            {
                _chunk.surface_lighting = surface_create(CHUNK_SIZE + RENDER_LIGHTING_PADDING, CHUNK_SIZE + RENDER_LIGHTING_PADDING, surface_r8unorm);
                _needs_update = true;
            }
            
            // Check refresh flag
            if (_chunk.boolean & CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH)
            {
                _chunk.boolean ^= CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
                _needs_update = true;
            }
            
            // Only redraw if needed
            if (!_needs_update) continue;
            
            // Batch all draw operations for this surface
            surface_set_target(_chunk.surface_lighting);
            draw_clear_alpha(c_black, 1);
            
            var _chunk_covered = _chunk.chunk_covered;
            
            // Optimize inner loop - check full bytes first
            for (var l = 0; l < CHUNK_SIZE; ++l)
            {
                var _data = _chunk_covered[l];
                
                // Skip row entirely if all bits are set (all covered)
                if (_data == (1 << CHUNK_SIZE) - 1) continue;
                
                // If no bits set (none covered), draw entire row quickly
                if (_data == 0)
                {
                    var _x2 = _padding_offset + l;
                    
                    draw_sprite_ext(spr_Light, 0, _x2, _padding_offset + CHUNK_SIZE, 1, 1 + (CHUNK_SIZE / 16), 0, c_white, 1);
                    
                    continue;
                }
                
                // Mixed case - check individual bits
                var _x2 = _padding_offset + l;
                
                var _c = 0;
                
                for (var m = 0; m < CHUNK_SIZE; ++m)
                {
                    if !(_data & (1 << m))
                    {
                        ++_c;
                    }
                    else if (_c > 0)
                    {
                        draw_sprite_ext(spr_Light, 0, _x2, _padding_offset + m, 1, 1 + (_c / 16), 0, c_white, 1);
                        
                        _c = 0;
                    }
                }
            }
            
            surface_reset_target();
        }
        
        if (!surface_exists(surface_lighting))
        {
            surface_lighting = surface_create(_surface_lighting_width, _surface_lighting_height);
        }
        
        gpu_set_blendmode(bm_add);
        
        surface_set_target(surface_lighting);
        draw_clear_alpha(c_black, 1);
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];
            
            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            if (surface_exists(_chunk.surface_lighting))
            {
                var _x2 = ((_chunk.x - _surface_x) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);
                var _y2 = ((_chunk.y - _surface_y) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);
                
                draw_surface(_chunk.surface_lighting, _x2, _y2 + 8);
            }
        }
        
        with (obj_Player)
        {
            var _x = ((x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
            var _y = ((y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE);
            
            draw_sprite_ext(spr_Light, 0, _x, _y + 8 - 1, 1, 1, 0, c_white, 1);
        }
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];
            
            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            var _lights = _chunk.chunk_lights;
            var _lights_length = array_length(_lights);
            
            for (var j = 0; j < _lights_length; ++j)
            {
                var _light = _lights[j];
                
                var _x = ((_light.x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
                var _y = ((_light.y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE);
                
                draw_sprite_ext(spr_Light, 0, _x, _y + 8, 1, 1, 0, _light.image_blend, 1);
            }
        }
        
        surface_reset_target();
        
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    }
    
    gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
    
    if (surface_exists(surface_lighting))
    {
        shader_set(shd_Lighting);
        
        // var _u_resolution = shader_get_uniform(shd_Lighting, "u_resolution");
        
        // shader_set_uniform_f(_u_resolution, _surface_lighting_width * RENDER_LIGHTING_RESIZE, _surface_lighting_height * RENDER_LIGHTING_RESIZE);
        
        var _x2 = _surface_x - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2) + TILE_SIZE;
        var _y2 = _surface_y - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2) + TILE_SIZE;
        
        draw_surface_ext(surface_lighting, _x2, _y2, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 0.8);
        
        gpu_set_tex_filter(true);
        
        draw_surface_ext(surface_lighting, _x2, _y2, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);
        
        gpu_set_tex_filter(false);
        
        shader_reset();
    }
    
    draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _camera_width + _camera_width, _camera_y + _camera_height, 0, obj_Game_Control_Background.light_colour, 1);
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
}