function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    
    if (chance(0.01 * _dt))
    {
        if (chance(0.2))
        {
            if (input_left) || (input_right)
            {
                input_left = !input_left;
                input_right = !input_right;
            }
            else
            {
            	if (chance(0.5))
                {
                	input_left = true;
                	input_right = false;
                }
                else
                {
                	input_left = false;
                	input_right = true;
                }
            }
        }
        else
        {
        	input_left = false;
        	input_right = false;
        }
    }
    
    control_physics_input(_dt, id);
    control_physics(_dt, id);
    
    if ((input_left) || (input_right)) && (tile_meeting(x, y + 1))
    {
        timer_sfx_step += _dt / GAME_TICK;
        
        if (timer_sfx_step >= 0.28)
        {
            timer_sfx_step = 0;
            
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
                sfx_diegetic_play(audio_emitter, x, y, global.item_data[$ _tile.get_id()].get_sfx_step());
            }
            else
            {
                timer_sfx_step = 0.28;
            }
        }
    }
    else
    {
        timer_sfx_step = 0.28;
    }
    
    control_physics_input_after(_dt, id);
}