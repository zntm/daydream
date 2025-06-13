function control_player(_dt)
{
    audio_listener_position(x, y, 0);
    
    control_physics_input(_dt, id);
    control_physics(_dt, id);
    
    if ((input_left) || (input_right)) && (tile_meeting(x, y + 1))
    {
        timer_sfx_step -= _dt / GAME_TICK;
        
        if (timer_sfx_step <= 0)
        {
            timer_sfx_step = 0.28;
            
            var _tile_x = round(x / TILE_SIZE);
            var _tile_y = round(y / TILE_SIZE);
            
            var _tile = tile_get(_tile_x, _tile_y - 1, CHUNK_DEPTH_FOLIAGE_BACK);
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x, _tile_y - 1, CHUNK_DEPTH_FOLIAGE_FRONT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x - 1, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x + 1, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile != TILE_EMPTY)
            {
                sfx_diegetic_play(x, y, global.item_data[$ _tile.get_id()].get_sfx_step());
            }
            else
            {
                timer_sfx_step = 0;
            }
        }
    }
    else
    {
        timer_sfx_step = 0;
    }
    
    control_physics_input_after(_dt, id);
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
}