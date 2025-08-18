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
        
        if (timer_respawn > 0)
        {
            timer_respawn -= _tick / GAME_TICK;
            
            if (timer_respawn <= 0)
            {
                obj_Player.x = obj_Player.xspawn;
                obj_Player.y = obj_Player.yspawn;
                
                obj_Player.xvelocity = 0;
                obj_Player.yvelocity = 0;
                
                obj_Player.hp = obj_Player.hp_max;
                
                _camera_x = obj_Player.x - (_camera_width  / 2);
                _camera_y = obj_Player.y - (_camera_height / 2);
                
                control_camera_pos(_camera_x, _camera_y, true);
            }
        }
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if (!instance_exists(_inst)) || !(_inst.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            var _chunk_xstart = _inst.chunk_xstart;
            var _chunk_ystart = _inst.chunk_ystart;
            
            var _chunk = _inst.chunk;
            var _chunk_count = _inst.chunk_count;
            var _chunk_display = _inst.chunk_display;
            
            repeat (4)
            {
                var _x2 = irandom(CHUNK_SIZE - 1);
                var _y2 = irandom(CHUNK_SIZE - 1);
                
                var _z = irandom(CHUNK_DEPTH - 1);
                var _bitmask = 1 << _z;
                
                if !(_chunk_display & _bitmask) || (_chunk_count[_z] <= 0) continue;
                
                var _tile = _chunk[tile_index_xyz(_x2, _y2, _z)];
                
                if (_tile == TILE_EMPTY) continue;
                
                var _data = _item_data[$ _tile.get_id()];
                
                var _on_random_tick = _data.get_on_random_tick();
                var _on_random_tick_length = _data.get_on_random_tick_length();
                
                for (var j = 0; j < _on_random_tick_length; ++j)
                {
                    var _random_tick = _on_random_tick[j];
                    
                    if (!chance(_random_tick[0] * _tick)) continue;
                    
                    var _random_tick_length = _random_tick[1];
                    
                    var _ = _random_tick[2];
                    
                    var _id = _[0];
                    
                    if (_id != undefined)
                    {
                        var _function = _item_function[$ _id];
                        var _parameter = _[1];
                        
                        repeat (smart_value(_[2]))
                        {
                            _function(_tick, _chunk_xstart + _x2, _chunk_ystart + _y2, _z, _parameter);
                        }
                    }
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
    }
}