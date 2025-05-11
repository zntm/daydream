function control_game_tick()
{
    for (var _delta_time = global.delta_time; _delta_time > 0; _delta_time -= 1)
    {
        var _tick = min(1, _delta_time);
        
        with (obj_Player)
        {
            control_player(_tick);
        }
    }
}