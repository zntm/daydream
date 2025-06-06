function control_game_tick()
{
    var _delta_time = global.delta_time;
    
    var _time_length = global.world_data[$ global.world.dimension].get_time_length();
    
    for (var _dt = GAME_TICK * _delta_time; _delta_time > 0; _delta_time -= 1)
    {
        var _tick = min(1, _dt);
        
        with (obj_Player)
        {
            control_player(_tick);
        }
        
        with (obj_Item_Drop)
        {
            control_item_drop(_tick);
        }
        
        with (obj_Floating_Text)
        {
            control_floating_text(_tick);
        }
        
        global.world.time += _dt / GAME_TICK;
        
        if (global.world.time >= _time_length)
        {
            global.world.time %= _time_length;
            
            ++global.world.day;
        }
    }
}