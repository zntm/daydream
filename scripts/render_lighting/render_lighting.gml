#macro SURFACE_LIGHTING_SIZE (1 / 16)

#macro RENDER_LIGHTING_RESIZE 16
#macro RENDER_LIGHTING_PADDING 16

function render_lighting(_a, _b, _xstart, _ystart, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _surface_lighting_width  = ceil(_camera_width  / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    var _surface_lighting_height = ceil(_camera_height / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    
    var _surface_x = round(_camera_x / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    var _surface_y = round(_camera_y / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.LIGHTING)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        if (!surface_exists(surface_lighting))
        {
            surface_lighting = surface_create(_surface_lighting_width, _surface_lighting_height);
        }
        
        surface_set_target(surface_lighting);
        draw_clear_alpha(c_black, 0);
        
        draw_sprite_ext(spr_Square, 0, 0, 0, _surface_lighting_width, _surface_lighting_height, 0, c_black, 1);
        
        gpu_set_blendmode(bm_subtract);
        
        for (var i = -_a; i < _a; ++i)
        {
            var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);
            
            for (var j = -_b; j < _b; ++j)
            {
                var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);
                
                var _inst = instance_position(_x, _y, obj_Chunk);
                
                if (!instance_exists(_inst)) || (!_inst.is_generated) continue;
                
                if !(_inst.chunk_display)
                {
                    var _x2 = (_x + RENDER_LIGHTING_PADDING + (CHUNK_SIZE_DIMENSION / 2) - _surface_x) / RENDER_LIGHTING_RESIZE;
                    var _y2 = (_y + RENDER_LIGHTING_PADDING + (CHUNK_SIZE_DIMENSION)     - _surface_y) / RENDER_LIGHTING_RESIZE;
                    
                    draw_sprite_ext(spr_Light, 0, _x2, _y2 + 8, CHUNK_SIZE, CHUNK_SIZE, 0, c_white, 1);
                    
                    continue;
                }
                
                var _xcenter = _inst.xcenter;
                var _ycenter = _inst.ycenter;
                
                var _light = instance_nearest(_xcenter, _ycenter, obj_Parent_Light);
                
                if (!instance_exists(_light)) || (rectangle_distance(_light.x, _light.y, _xcenter - (CHUNK_SIZE_DIMENSION / 2), _ycenter - (CHUNK_SIZE_DIMENSION / 2), _xcenter + (CHUNK_SIZE_DIMENSION / 2), _ycenter + (CHUNK_SIZE_DIMENSION / 2)) >= (CHUNK_SIZE_DIMENSION * 3)) continue;
                
                var _chunk_covered = _inst.chunk_covered;
                
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _data = _chunk_covered[l];
                    
                    if !(_data)
                    {
                        var _x2 = (_x + RENDER_LIGHTING_PADDING + (CHUNK_SIZE_DIMENSION / 2) - _surface_x) / RENDER_LIGHTING_RESIZE;
                        var _y2 = (_y + RENDER_LIGHTING_PADDING + (CHUNK_SIZE_DIMENSION)     - _surface_y) / RENDER_LIGHTING_RESIZE;
                        
                        draw_sprite_ext(spr_Light, 0, _x2, _y + 8, 1, CHUNK_SIZE, 0, c_white, 1);
                        
                        continue;
                    }
                    
                    var _is_drawn = false;
                    
                    var _length = 0;
                    
                    for (var m = 0; m < CHUNK_SIZE; ++m)
                    {
                        _is_drawn = false;
                        
                        if !(_data & (1 << m))
                        {
                            ++_length;
                            
                            continue;
                        }
                        
                        if (_length > 0)
                        {
                            _is_drawn = true;
                            
                            var _x2 = (_x + (RENDER_LIGHTING_PADDING + l * TILE_SIZE) - _surface_x) / RENDER_LIGHTING_RESIZE;
                            var _y2 = (_y + RENDER_LIGHTING_PADDING + (m * TILE_SIZE) - _surface_y) / RENDER_LIGHTING_RESIZE;
                            
                            if (rectangle_in_rectangle(0, 0, _surface_lighting_width, _surface_lighting_height, _x2 - 8, _y2 - (CHUNK_SIZE * 16) - 8, _x2 + 8, _y2 + 8))
                            {
                                draw_sprite_ext(spr_Light, 0, _x2, _y2 + 8, 1, _length, 0, c_white, 1);
                            }
                            
                            _length = 0;
                        }
                    }
                    
                    if (!_is_drawn)
                    {
                        var _x2 = (_x + (RENDER_LIGHTING_PADDING + l * TILE_SIZE) - _surface_x) / RENDER_LIGHTING_RESIZE;
                        var _y2 = (_y + RENDER_LIGHTING_PADDING + (m * TILE_SIZE) - _surface_y) / RENDER_LIGHTING_RESIZE;
                        
                        if (rectangle_in_rectangle(0, 0, _surface_lighting_width, _surface_lighting_height, _x2 - 8, _y2 - (CHUNK_SIZE * 16) - 8, _x2 + 8, _y2 + 8))
                        {
                            draw_sprite_ext(spr_Light, 0, _x2, _y2 + 8, 1, _length, 0, c_white, 1);
                        }
                    }
                }
            }
        }
        
        with (obj_Player)
        {
            var _x = ((x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
            var _y = ((y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE) + 8;
            
            draw_sprite_ext(spr_Light, 0, _x, _y, 1, 1, 0, c_white, 1);
            
            /*
            var _tile_x = x / RENDER_LIGHTING_RESIZE;
            var _tile_y = y / RENDER_LIGHTING_RESIZE;
            
            var _x = round(_tile_x) - round(_camera_x / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING / RENDER_LIGHTING_RESIZE);
            var _y = round(_tile_y) - round(_camera_y / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING / RENDER_LIGHTING_RESIZE) + 8;
            
            // var _x = ((x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
            // var _y = ((y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE) + 8;
            
            var _ax = floor(_tile_x);
            var _ay = floor(_tile_y);
            
            var _bx = ceil(_tile_x);
            var _by = ceil(_tile_y);
            
            var _normalized_x = normalize(_tile_x, _ax, _bx);
            var _normalized_y = normalize(_tile_y, _ay, _by);
            
            draw_sprite_ext(spr_Light, 0, _x + 1, _y, 1, 1, 0, c_white,     (_normalized_x) * 0.5);
            draw_sprite_ext(spr_Light, 0, _x - 1, _y, 1, 1, 0, c_white, (1 - _normalized_x) * 0.5);
            
            draw_sprite_ext(spr_Light, 0, _x, _y + 1, 1, 1, 0, c_white,     (_normalized_y) * 0.5);
            draw_sprite_ext(spr_Light, 0, _x, _y - 1, 1, 1, 0, c_white, (1 - _normalized_y) * 0.5);
            
            // draw_sprite_ext(spr_Light, 0, _x, _y, 1, 1, 0, c_white, 1);
            */
        }
        
        surface_reset_target();
        
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    }
    
    if (surface_exists(surface_lighting))
    {
        draw_surface_ext(surface_lighting, _surface_x - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2), _surface_y - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2), RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);
    }
    /*
    gpu_set_tex_filter(true);
    
    draw_surface_ext(surface_lighting, _camera_x - RENDER_LIGHTING_PADDING, _camera_y - RENDER_LIGHTING_PADDING, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);
    
    gpu_set_tex_filter(false);
    */
    gpu_set_blendmode_ext(bm_dest_color, bm_zero);
    
    draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _camera_width + _camera_width, _camera_y + _camera_height, 0, obj_Game_Control_Background.light_colour, 1);
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
}