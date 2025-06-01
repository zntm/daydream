function control_game_tick()
{
    var _time_length = global.world_data[$ global.world.dimension].get_time_length();
    
    for (var _delta_time = GAME_TICK * global.delta_time; _delta_time > 0; _delta_time -= 1)
    {
        var _dt = min(1, _delta_time);
        
        with (obj_Player)
        {
            control_player(_dt);
        }
        
        with (obj_Item_Drop)
        {
            control_item_drop(_dt);
        }
        
        with (obj_Floating_Text)
        {
            control_floating_text(_dt);
        }
        
        global.world.time += _dt / GAME_TICK;
        
        if (global.world.time >= _time_length)
        {
            global.world.time %= _time_length;
            
            ++global.world.day;
        }
    }
}