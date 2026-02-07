function bg_sky_colour(_in_region_data, _in_region_transition_data)
{
    var _world_save_data = global.world_save_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _world_time = _world_save_data.time;
    var _time_norm = _world_time / _world_data.get_time_length();
    
    var _sky_colour_base_from = _in_region_data.get_sky_colour_base(_time_norm);
    var _sky_colour_gradient_from = _in_region_data.get_sky_colour_gradient(_time_norm);
    var _light_colour_from = _in_region_data.get_light_colour(_time_norm);
    
    var _t = min(1, in_region_transition_value);
    
    if (_t <= 0)
    {
        sky_colour_base = _sky_colour_base_from;
        sky_colour_gradient = _sky_colour_gradient_from;
        light_colour = _light_colour_from;
    }
    else
    {
        var _sky_colour_base_to = _in_region_transition_data.get_sky_colour_base(_time_norm);
        var _sky_colour_gradient_to = _in_region_transition_data.get_sky_colour_gradient(_time_norm);
        var _light_colour_to = _in_region_transition_data.get_light_colour(_time_norm);
        
        sky_colour_base = merge_color(_sky_colour_base_from, _sky_colour_base_to, _t);
        sky_colour_gradient = merge_color(_sky_colour_gradient_from, _sky_colour_gradient_to, _t);
        light_colour = merge_color(_light_colour_from, _light_colour_to, _t);
    }
}