function bg_sky_colour(_in_biome_data, _in_biome_transition_data)
{
    var _world_save_data = global.world_save_data;
    var _world_time = _world_save_data.time;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _time_diurnal_length = _world_data.get_time_diurnal_length();
    
    for (var i = 0; i < _time_diurnal_length; ++i)
    {
        var _name_from = _world_data.get_time_diurnal_name(i);
        
        var _start_from = _world_data.get_time_diurnal_start(_name_from);
        var _end_from   = _world_data.get_time_diurnal_end(_name_from);
        
        if (_world_time < _start_from) || (_world_time >= _end_from) continue;
        
        var _name_to = _world_data.get_time_diurnal_name((i + 1) % _time_diurnal_length);
        
        var _start_to = _world_data.get_time_diurnal_start(_name_to);
        var _end_to   = _world_data.get_time_diurnal_end(_name_to);
        
        var _sky_colour_base_from = _in_biome_data.get_sky_colour_base(_name_from);
        var _sky_colour_base_to   = _in_biome_data.get_sky_colour_base(_name_to);
        
        var _sky_colour_gradient_from = _in_biome_data.get_sky_colour_gradient(_name_from);
        var _sky_colour_gradient_to   = _in_biome_data.get_sky_colour_gradient(_name_to);
        
        var _light_colour_from = _in_biome_data.get_light_colour(_name_from);
        var _light_colour_to   = _in_biome_data.get_light_colour(_name_to);
        
        var _t = normalize(_world_time, _start_from, _end_from);
        
        if (in_biome_transition_value <= 0)
        {
            sky_colour_base     = merge_colour(_sky_colour_base_from,     _sky_colour_base_to,     _t);
            sky_colour_gradient = merge_colour(_sky_colour_gradient_from, _sky_colour_gradient_to, _t);
            
            light_colour = merge_colour(_light_colour_from, _light_colour_to, _t);
        }
        else
        {
            var _transition_sky_colour_base_from = _in_biome_transition_data.get_sky_colour_base(_name_from);
            var _transition_sky_colour_base_to   = _in_biome_transition_data.get_sky_colour_base(_name_to);
            
            var _transition_sky_colour_gradient_from = _in_biome_transition_data.get_sky_colour_gradient(_name_from);
            var _transition_sky_colour_gradient_to   = _in_biome_transition_data.get_sky_colour_gradient(_name_to);
            
            if (_transition_sky_colour_base_from != _transition_sky_colour_gradient_from) || (_transition_sky_colour_base_to != _transition_sky_colour_gradient_to)
            {
                var _sky_colour_base     = merge_colour(_sky_colour_base_from,     _sky_colour_base_to,     _t);
                var _sky_colour_gradient = merge_colour(_sky_colour_gradient_from, _sky_colour_gradient_to, _t);
                
                var _transition_sky_colour_base     = merge_colour(_transition_sky_colour_base_from,     _transition_sky_colour_base_to,     _t);
                var _transition_sky_colour_gradient = merge_colour(_transition_sky_colour_gradient_from, _transition_sky_colour_gradient_to, _t);
                
                sky_colour_base     = merge_colour(_sky_colour_base,     _transition_sky_colour_base,     in_biome_transition_value);
                sky_colour_gradient = merge_colour(_sky_colour_gradient, _transition_sky_colour_gradient, in_biome_transition_value);
            }
            
            var _transition_light_colour_from = _in_biome_transition_data.get_light_colour(_name_from);
            var _transition_light_colour_to   = _in_biome_transition_data.get_light_colour(_name_to);
            
            if (_light_colour_from != _transition_light_colour_from) || (_light_colour_to != _transition_light_colour_to)
            {
                var _light_colour            = merge_colour(_light_colour_from,            _light_colour_to,            _t);
                var _transition_light_colour = merge_colour(_transition_light_colour_from, _transition_light_colour_to, _t);
                
                light_colour = merge_colour(_light_colour, _transition_light_colour, in_biome_transition_value);
            }
        }
        
        break;
    }
}