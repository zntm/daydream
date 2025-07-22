function control_player(_dt)
{
    audio_listener_position(x, y, 0);
    
    control_physics_input(_dt, id);
    
    var _on_ground = tile_meeting(x, y + 1);
    
    control_physics_creative(_dt, id);
    
    if (y > ylast)
    {
        if (!_on_ground) && (tile_meeting(x, y + 1))
        {
            var _difference = y - ylast;
            
            var _value = floor(1 * (power(round(_difference / TILE_SIZE) / 0.8, 1.25) - 12));
            
            if (_value > 0)
            {
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                
                hp -= _value;
                
                ylast = y;
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                /*
                ylast = y;
                
                hp_add(id, -_value, DAMAGE_TYPE.FALL);
                
                return true;
                */
            }
        }
    }
    else
    {
        ylast = y;
    }
    
    var _refresh = (xvelocity != 0) || (yvelocity != 0);
    
    control_entity_sfx(_dt);
    
    control_physics_input_after(_dt, id);
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
    
    if (hp < hp_max)
    {
        timer_regeneration -= (_dt / GAME_TICK) * (1 + min(0.68, saturation * 0.08));
        
        if (timer_regeneration <= 0)
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
            
            timer_regeneration = 2.4;
            
            ++hp;
            
            if (saturation > 0)
            {
                --saturation;
            }
        }
    }
    
    if (_refresh)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _camera_x = global.camera_x_real;
        var _camera_y = global.camera_y_real;
        
        var _camera_width  = global.camera_width;
        var _camera_height = global.camera_height;
        
        var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        
        if (_xstart != obj_Game_Control.chunk_in_view_x) || (_ystart != obj_Game_Control.chunk_in_view_y)
        {
            obj_Game_Control.chunk_in_view_x = _xstart;
            obj_Game_Control.chunk_in_view_y = _ystart;                                              
            
            control_update_chunk_in_view();
        }
    }
}