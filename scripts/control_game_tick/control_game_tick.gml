function control_game_tick()
{
    var _delta_time = global.delta_time;
    
    var _time_length = global.world_data[$ global.world_save_data.dimension].get_time_length();
    
    for (var _dt = GAME_TICK * _delta_time; _delta_time > 0; _delta_time -= 1)
    {
        var _tick = min(1, _dt);
        
        control_creature_spawn(_tick);
        
        with (obj_Player)
        {
            control_player(_tick);
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
        
        global.world_save_data.time += _dt / GAME_TICK;
        
        if (global.world_save_data.time >= _time_length)
        {
            global.world_save_data.time %= _time_length;
            
            ++global.world_save_data.day;
        }
    }
}