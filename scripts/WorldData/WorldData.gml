function WorldData(_world_height) constructor
{
    ___world_height = _world_height;
    
    static get_world_height = function()
    {
        return ___world_height & 0xffff;
    }
    
    static set_vignette = function(_start, _end, _colour)
    {
        ___vignette = (hex_parse(_colour) << 32) | (_end << 16) | _start;
        
        return self;
    }
    
    static get_vignette_start = function()
    {
        return ___vignette & 0xffff;
    }
    
    static get_vignette_end = function()
    {
        return (___vignette >> 16) & 0xffff;
    }
    
    static get_vignette_colour = function()
    {
        return (___vignette >> 32) & 0xffffff;
    }
    
    static set_time = function(_time_length, _time_diurnal)
    {
        ___time_length = _time_length;
        ___time_diurnal = {}
        
        var _names = struct_get_names(_time_diurnal);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            var _data = _time_diurnal[$ _name];
            
            ___time_diurnal[$ _name] = (_data[$ "end"] << 16) | _data.start;
        }
        
        return self;
    }
    
    static get_time_length = function()
    {
        return ___time_length;
    }
    
    static get_time_diurnal_start = function(_time_diurnal)
    {
        return ___time_diurnal[$ _time_diurnal] & 0xffff;
    }
    
    static get_time_diurnal_end = function(_time_diurnal)
    {
        return (___time_diurnal[$ _time_diurnal] >> 16) & 0xffff;
    }
    
    static set_surface_biome = function(_surface)
    {
        var _humidity = _surface.humidity;
        var _heat = _surface.heat;
        
        ___surface_biome_octave_humidity = _humidity.octave;
        ___surface_biome_octave_heat = _heat.octave;
        
        ___surface_biome_value = (_heat.roughness << 8) | _humidity.roughness;
        
        return self;
    }
    
    static get_surface_biome_humidity_octave = function(_surface)
    {
        return ___surface_biome_octave_humidity;
    }
    
    static get_surface_biome_humidity_roughness = function(_surface)
    {
        return ___surface_biome_value & 0xff;
    }
    
    static get_surface_biome_heat_octave = function(_surface)
    {
        return ___surface_biome_octave_heat;
    }
    
    static get_surface_biome_heat_roughness = function(_surface)
    {
        return (___surface_biome_value >> 8) & 0xff;
    }
    
    static set_surface = function(_start, _offset)
    {
        ___surface_value = (_offset.roughness << 48) | (_offset.max << 32) | (_offset.min << 16) | _start;
        ___surface_octave = _offset.octave;
        
        return self;
    }
    
    static get_surface_start = function()
    {
        return ___surface_value & 0xffff;
    }
    
    static get_surface_offset_min = function()
    {
        return (___surface_value >> 16) & 0xffff;
    }
    
    static get_surface_offset_max = function()
    {
        return (___surface_value >> 32) & 0xffff;
    }
    
    static get_surface_offset_roughness = function()
    {
        return (___surface_value >> 48) & 0xff;
    }
    
    static get_surface_offset_octave = function()
    {
        return ___surface_octave;
    }
    
    static set_cave = function(_start, _system)
    {
        var _system_length = array_length(_system);
        
        ___cave_value = (_system_length << 40) | (_start.roughness << 32) | (_start.max << 16) | _start.min;
        ___cave_start_octave = _start.octave;
        
        ___cave_system = array_create(_system_length);
        
        for (var i = 0; i < _system_length; ++i)
        {
            var _data = _system[i];
            
            var _range = _data.range;
            var _threshold = _data.threshold;
            
            ___cave_system[@ i] = {
                ___value: (_threshold.roughness << 48) | (_threshold.max << 40) | (_threshold.min << 32) | (_range.max << 16) | _range.min,
                ___octave: _threshold.octave
            }
        }
        
        return self;
    }
    
    static get_cave_start_min = function()
    {
        return ___cave_value & 0xffff;
    }
    
    static get_cave_start_max = function()
    {
        return (___cave_value >> 16) & 0xffff;
    }
    
    static get_cave_start_roughness = function()
    {
        return (___cave_value >> 32) & 0xffff;
    }
    
    static get_cave_system_length = function()
    {
        return (___cave_value >> 40) & 0xffff;
    }
    
    static get_cave_start_octave = function()
    {
        return ___cave_start_octave;
    }
    
    static get_cave_system_range_min = function(_index)
    {
        return ___cave_system[_index].___value & 0xffff;
    }
    
    static get_cave_system_range_max = function(_index)
    {
        return (___cave_system[_index].___value >> 16) & 0xffff;
    }
    
    static get_cave_system_threshold_min = function(_index)
    {
        return (___cave_system[_index].___value >> 32) & 0xff;
    }
    
    static get_cave_system_threshold_max = function(_index)
    {
        return (___cave_system[_index].___value >> 40) & 0xff;
    }
    
    static get_cave_system_threshold_roughness = function(_index)
    {
        return (___cave_system[_index].___value >> 48) & 0xff;
    }
    
    static get_cave_system_threshold_octave = function(_index)
    {
        return ___cave_system[_index].___octave;
    }
    
    static set_surface_biome_map = function(_surface_biome_map)
    {
        ___surface_biome_map = _surface_biome_map;
        
        return self;
    }
    
    static get_surface_biome_map = function()
    {
        return ___surface_biome_map;
    }
}