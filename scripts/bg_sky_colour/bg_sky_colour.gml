function bg_sky_colour(_in_biome_data, _in_biome_transition_data)
{
    var _world_save_data = global.world_save_data;
    var _world_time = _world_save_data.time;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _time_diurnal = _world_data.get_time_diurnal();
    var _time_diurnal_length = _world_data.get_time_diurnal_length();
    
    for (var i = 0; i < _time_diurnal_length; ++i)
    {
        var _from = _time_diurnal[i];
        
        var _name_from = _from.id;
        
        var _start_from = _from.time_range_min;
        var _end_from   = _from.time_range_max;
        
        if (_world_time < _start_from) || (_world_time >= _end_from) continue;
        
        var _to = _time_diurnal[(i + 1) % _time_diurnal_length];
        
        var _name_to = _to.id;
        
        var _start_to = _to.time_range_min;
        var _end_to   = _to.time_range_max;
        
        // Safety Fallbacks for missing biome data or missing diurnal keys
        var _get_sky_base = function(_data, _name) {
            if (_data == undefined) return 0x5F91FE; // Default Sky Blue
            var _val = _data.get_sky_colour_base(_name);
            return _val ?? 0x5F91FE;
        };
        
        var _get_sky_grad = function(_data, _name) {
            if (_data == undefined) return 0x244FE9; // Default Sky Gradient
            var _val = _data.get_sky_colour_gradient(_name);
            return _val ?? 0x244FE9;
        };
        
        var _get_light = function(_data, _name) {
            if (_data == undefined) return 0xFFFFFF; // Default White
            var _val = _data.get_light_colour(_name);
            return _val ?? 0xFFFFFF;
        };
        
        var _sky_colour_base_from = _get_sky_base(_in_biome_data, _name_from);
        var _sky_colour_base_to   = _get_sky_base(_in_biome_data, _name_to);
        
        var _sky_colour_gradient_from = _get_sky_grad(_in_biome_data, _name_from);
        var _sky_colour_gradient_to   = _get_sky_grad(_in_biome_data, _name_to);
        
        var _light_colour_from = _get_light(_in_biome_data, _name_from);
        var _light_colour_to   = _get_light(_in_biome_data, _name_to);
        
        var _t  = min(1, normalize(_world_time, _start_from, _end_from));
        var _t2 = min(1, in_biome_transition_value);
        
        if (in_biome_transition_value <= 0)
        {
            sky_colour_base     = merge_colour(_sky_colour_base_from,     _sky_colour_base_to,     _t);
            sky_colour_gradient = merge_colour(_sky_colour_gradient_from, _sky_colour_gradient_to, _t);
            
            light_colour = merge_colour(_light_colour_from, _light_colour_to, _t);
        }
        else
        {
            var _transition_sky_colour_base_from = _get_sky_base(_in_biome_transition_data, _name_from);
            var _transition_sky_colour_base_to   = _get_sky_base(_in_biome_transition_data, _name_to);
            
            var _transition_sky_colour_gradient_from = _get_sky_grad(_in_biome_transition_data, _name_from);
            var _transition_sky_colour_gradient_to   = _get_sky_grad(_in_biome_transition_data, _name_to);
            
            if (_transition_sky_colour_base_from != _transition_sky_colour_gradient_from) || (_transition_sky_colour_base_to != _transition_sky_colour_gradient_to)
            {
                var _sky_colour_base     = merge_colour(_sky_colour_base_from,     _sky_colour_base_to,     _t);
                var _sky_colour_gradient = merge_colour(_sky_colour_gradient_from, _sky_colour_gradient_to, _t);
                
                var _transition_sky_colour_base     = merge_colour(_transition_sky_colour_base_from,     _transition_sky_colour_base_to,     _t);
                var _transition_sky_colour_gradient = merge_colour(_transition_sky_colour_gradient_from, _transition_sky_colour_gradient_to, _t);
                
                sky_colour_base     = merge_colour(_sky_colour_base,     _transition_sky_colour_base,     _t2);
                sky_colour_gradient = merge_colour(_sky_colour_gradient, _transition_sky_colour_gradient, _t2);
            }
            
            var _transition_light_colour_from = _get_light(_in_biome_transition_data, _name_from);
            var _transition_light_colour_to   = _get_light(_in_biome_transition_data, _name_to);
            
            if (_light_colour_from != _transition_light_colour_from) || (_light_colour_to != _transition_light_colour_to)
            {
                var _light_colour            = merge_colour(_light_colour_from,            _light_colour_to,            _t);
                var _transition_light_colour = merge_colour(_transition_light_colour_from, _transition_light_colour_to, _t);
                
                light_colour = merge_colour(_light_colour, _transition_light_colour, _t2);
            }
        }
        
        break;
    }
}