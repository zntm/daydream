function control_game_tick(_delta_time)
{
    var _item_data = global.item_data;
    var _item_function = global.item_function;
    
    var _dt = GAME_TICK * _delta_time;
    
    global.tick_accumulator += _dt;
    
    var _time_length = global.world_data[$ global.world_save_data.dimension].get_time_length();
    
    var _camera_x = global.camera_x_real;
    var _camera_y = global.camera_y_real;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    while (global.tick_accumulator >= 1)
    {
        var _tick = min(1, global.tick_accumulator);
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if (!_inst.is_generated) continue;
            
            repeat (4)
            {
                var _x2 = irandom(CHUNK_SIZE - 1);
                var _y2 = irandom(CHUNK_SIZE - 1);
                
                var _z = irandom(CHUNK_DEPTH - 1);
                var _bitmask = 1 << _z;
                
                if !(_inst.chunk_display & _bitmask) || (_inst.chunk_count[_z] <= 0) continue;
                
                var _tile = _inst.chunk[tile_index(_x2, _y2, _z)];
                
                if (_tile == TILE_EMPTY) continue;
                
                var _data = _item_data[$ _tile.get_id()];
                
                if (!chance(_data.get_on_random_tick_chance())) continue;
                
                var _function = _data.get_on_random_tick_function();
                
                if (_function != undefined)
                {
                    _item_function[$ _function](_inst.chunk_xstart + _x2, _inst.chunk_ystart + _y2, _data.get_on_random_tick_parameter());
                }
            }
        }
        
        control_creature_spawn(_tick);
        
        with (obj_Player)
        {
            control_player(_tick);
        }
        
        with (obj_Particle)
        {
            control_particle(_tick);
        }
        
        with (obj_Creature)
        {
            control_creature(_tick);
        }
        
        with (obj_Item_Drop)
        {
            control_item_drop(_tick);
        }
        
        with (obj_Floating_Text)
        {
            control_floating_text(_tick);
        }
        
        global.world_save_data.time += _tick / GAME_TICK;
        
        if (global.world_save_data.time >= _time_length)
        {
            global.world_save_data.time %= _time_length;
            
            ++global.world_save_data.day;
        }
        
        global.tick_accumulator -= 1;
        
        // global.tick_accumulator = max(0, global.tick_accumulator - 1);
    }
}