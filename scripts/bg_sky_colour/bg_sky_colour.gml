function bg_sky_colour(_in_biome_data, _in_biome_transition_data)
{
    var _world_save_data = global.world_save_data;
    var _world_time = _world_save_data.time;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    var _time_length = _world_data.get_time_length();
    
    // Normalize time to 0.0 - 1.0
    var _norm_time = _world_time / max(1, _time_length);
    
    // Get colors for the current biome safely
    var _sky_c1   = worldgen_get_sky_colour(_in_biome_data, _norm_time);
    var _light_c1 = worldgen_get_light_colour(_in_biome_data, _norm_time);
    
    var _t2 = min(1, in_biome_transition_value);
    
    if (_t2 <= 0)
    {
        // No transition
        sky_colour_base     = _sky_c1;
        sky_colour_gradient = _sky_c1;
        light_colour        = _light_c1;
    }
    else
    {
        // Transitioning between biomes safely
        var _sky_c2   = worldgen_get_sky_colour(_in_biome_transition_data, _norm_time);
        var _light_c2 = worldgen_get_light_colour(_in_biome_transition_data, _norm_time);
        
        sky_colour_base     = merge_colour(_sky_c1, _sky_c2, _t2);
        sky_colour_gradient = merge_colour(_sky_c1, _sky_c2, _t2);
        light_colour        = merge_colour(_light_c1, _light_c2, _t2);
    }
}
