function control_game_tick()
{
    for (var _delta_time = 60 * global.delta_time; _delta_time > 0; _delta_time -= 1)
    {
        var _dt = min(1, _delta_time);
        
        show_debug_message($"{_delta_time}: {_dt}")
        
        with (obj_Player)
        {
            control_player(_dt);
        }
        
        global.world.time += _dt / 4;
    }
}