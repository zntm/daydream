#macro SURFACE_LIGHTING_SIZE (1 / 16)

#macro RENDER_LIGHTING_RESIZE 16
#macro RENDER_LIGHTING_PADDING 16

function render_lighting(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _surface_lighting_width  = ceil(_camera_width  / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    var _surface_lighting_height = ceil(_camera_height / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    
    var _surface_x = round(_camera_x / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    var _surface_y = round(_camera_y / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.LIGHTING)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if !(_inst.boolean & CHUNK_BOOLEAN.GENERATED) || !(_inst.boolean & CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH) continue;
            
            _inst.boolean ^= CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
            
            if (!surface_exists(_inst.surface_lighting))
            {
                _inst.surface_lighting = surface_create(CHUNK_SIZE + RENDER_LIGHTING_PADDING, CHUNK_SIZE + RENDER_LIGHTING_PADDING, surface_r8unorm);
            }
            
            surface_set_target(_inst.surface_lighting);
            draw_clear_alpha(c_black, 1);
            
            var _chunk_covered = _inst.chunk_covered;
            
            for (var l = 0; l < CHUNK_SIZE; ++l)
            {
                var _data = _chunk_covered[l];
                
                for (var m = 0; m < CHUNK_SIZE; ++m)
                {
                    if !(_data & (1 << m))
                    {
                        var _x2 = (RENDER_LIGHTING_PADDING / 2) + l;
                        var _y2 = (RENDER_LIGHTING_PADDING / 2) + m;
                        
                        draw_sprite_ext(spr_Light, 0, _x2, _y2, 1, 1, 0, c_white, 1);
                    }
                }
            }
            
            surface_reset_target();
        }
        
        if (!surface_exists(surface_lighting))
        {
            surface_lighting = surface_create(_surface_lighting_width, _surface_lighting_height, surface_r8unorm);
        }
        
        gpu_set_blendmode(bm_add);
        
        surface_set_target(surface_lighting);
        draw_clear_alpha(c_black, 1);
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if !(_inst.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            if (surface_exists(_inst.surface_lighting))
            {
                var _x2 = ((_inst.x - _surface_x) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);
                var _y2 = ((_inst.y - _surface_y) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);
                
                draw_surface(_inst.surface_lighting, _x2, _y2 + 8);
            }
        }
        
        with (obj_Player)
        {
            var _x = ((x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
            var _y = ((y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE);
            
            draw_sprite_ext(spr_Light, 0, _x, _y + 8, 1, 1, 0, c_white, 1);
        }
        
        surface_reset_target();
        
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    }
    
    gpu_set_blendmode_ext(bm_dest_color, bm_zero);
    
    if (surface_exists(surface_lighting))
    {
        shader_set(shd_Lighting);
        
        draw_surface_ext(surface_lighting, _surface_x - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2), _surface_y - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2), RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);
        /*
        gpu_set_tex_filter(true);
        
        draw_surface_ext(surface_lighting, _camera_x - RENDER_LIGHTING_PADDING, _camera_y - RENDER_LIGHTING_PADDING, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);
        
        gpu_set_tex_filter(false);
        */
        shader_reset();
    }
    
    draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _camera_width + _camera_width, _camera_y + _camera_height, 0, obj_Game_Control_Background.light_colour, 1);
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
}