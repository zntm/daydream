function WorldData(_namespace, _id, _world_height) : ParentData(_namespace, _id) constructor
{
    ___world_height = _world_height;
    
    static get_world_height = function()
    {
        return ___world_height & 0xffff;
    }
    
    static set_spawn_interval = function(_spawn_interval)
    {
        ___spawn_interval = _spawn_interval;
        
        return self;
    }
    
    static get_spawn_interval = function()
    {
        return ___spawn_interval;
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
    
    static set_time = function(_time)
    {
        var _time_diurnal = _time.diurnal;
        
        var _names = struct_get_names(_time_diurnal);
        var _length = array_length(_names);
        
        ___time_length = 0;
        ___time_start = _time.start;
        
        ___time_diurnal = {}
        ___time_diurnal_names = _names;
        ___time_diurnal_length = _length;
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            var _data = _time_diurnal[$ _name];
            
            var _start = _data.start;
            var _end   = _data[$ "end"];
            
            ___time_diurnal[$ _name] = (_end << 16) | _start;
            
            ___time_length = max(___time_length, _end);
        }
        
        array_sort(___time_diurnal_names, function(_a, _b)
        {
            return get_time_diurnal_start(_a) > get_time_diurnal_start(_b);
        });
        
        return self;
    }
    
    static get_time_start = function()
    {
        return ___time_start;
    }
    
    static get_time_length = function()
    {
        return ___time_length;
    }
    
    static get_time_diurnal_name = function(_index)
    {
        return ___time_diurnal_names[_index];
    }
    
    static get_time_diurnal_length = function()
    {
        return ___time_diurnal_length;
    }
    
    static get_time_diurnal_start = function(_time_diurnal)
    {
        return ___time_diurnal[$ _time_diurnal] & 0xffff;
    }
    
    static get_time_diurnal_end = function(_time_diurnal)
    {
        return (___time_diurnal[$ _time_diurnal] >> 16) & 0xffff;
    }
    
    static set_celestial = function(_sprite, _data)
    {
        ___celestial_sprite = _sprite;
        ___celestial_data = _data;
        
        ___celestial_names = struct_get_names(_data);
        ___celestial_length = array_length(___celestial_names);
        
        return self;
    }
    
    static get_celestial_name = function(_time)
    {
        for (var i = 0; i < ___celestial_length; ++i)
        {
            var _name = ___celestial_names[i];
            
            var _data = get_celestial_data(_name);
            
            if (_time >= _data.start) && (_time < _data[$ "end"])
            {
                return _name;
            }
        }
        
        return undefined;
    }
    
    static get_celestial_data = function(_name)
    {
        return ___celestial_data[$ _name];
    }
    
    static get_celestial_sprite = function(_name)
    {
        return ___celestial_sprite[$ _name];
    }
    
    static set_cave_biome = function(_cave)
    {
        static __transition_type = {
            "linear": WORLDGEN_CAVE_TRANSITION_TYPE.LINEAR,
            "random": WORLDGEN_CAVE_TRANSITION_TYPE.RANDOM
        }
        
        var _default = _cave[$ "default"];
        var _default_length = array_length(_default);
        
        ___cave_biome_default = array_create(_default_length);
        ___cave_biome_default_length = _default_length;
        
        for (var i = 0; i < _default_length; ++i)
        {
            var _data = _default[i];
            
            var _transition = _data.transition;
            
            ___cave_biome_default[@ i] = {
                ___id: _data.id,
                ___range: (_data[$ "end"] << 16) | _data.start,
                ___transition_value: (__transition_type[$ _transition.type] << 8) | _transition.amplitude,
                ___transition_octaves: _transition.octaves
            }
        }
        
        var _noise = _cave.noise;
        
        ___cave_biome_noise_octaves = _noise.octaves;
        
        var _options = _cave.options;
        var _options_length = array_length(_options);
        
        ___cave_biome_options = array_create(_options_length);
        
        for (var i = 0; i < _options_length; ++i)
        {
            
        }
    }
    
    static get_default_cave_id = function(_index)
    {
        return ___cave_biome_default[_index].___id;
    }
    
    static get_default_cave_start = function(_index)
    {
        return ___cave_biome_default[_index].___range & 0xffff;
    }
    
    static get_default_cave_end = function(_index)
    {
        return (___cave_biome_default[_index].___range >> 16) & 0xffff;
    }
    
    static get_default_cave_transition_amplitude = function(_index)
    {
        return ___cave_biome_default[_index].___transition_value & 0xff;
    }
    
    static get_default_cave_transition_octaves = function(_index)
    {
        return ___cave_biome_default[_index].___transition_octaves;
    }
    
    static get_default_cave_transition_type = function(_index)
    {
        return (___cave_biome_default[_index].___transition_value >> 8) & 0xff;
    }
    
    static get_default_cave_length = function(_index)
    {
        return ___cave_biome_default_length;
    }
    
    static set_surface_biome = function(_surface)
    {
        var _humidity = _surface.humidity;
        var _heat = _surface.heat;
        var _offset = _surface.offset;
        
        ___surface_biome_octaves_humidity = _humidity.octaves;
        ___surface_biome_octaves_heat = _heat.octaves;
        ___surface_biome_octaves_offset = _offset.octaves;
        
        ___surface_biome_value = (_offset.max << 8) | (_offset.min << 0);
        
        return self;
    }
    
    static get_surface_biome_humidity_octaves = function()
    {
        return ___surface_biome_octaves_humidity;
    }
    
    static get_surface_biome_offset_min = function()
    {
        return (___surface_biome_value >> 0) & 0xff;
    }
    
    static get_surface_biome_offset_max = function()
    {
        return (___surface_biome_value >> 8) & 0xff;
    }
    
    static get_surface_biome_heat_octaves = function()
    {
        return ___surface_biome_octaves_heat;
    }
    
    static get_surface_biome_offset_octaves = function()
    {
        return ___surface_biome_octaves_offset;
    }
    
    static set_surface = function(_start, _offset)
    {
        ___surface_value = (_offset.max << 32) | (_offset.min << 16) | _start;
        ___surface_octaves = _offset.octaves;
        
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
    
    static get_surface_offset_octaves = function()
    {
        return ___surface_octaves;
    }
    
    static set_cave = function(_start, _system)
    {
        var _system_length = array_length(_system);
        
        var _min = _start.min;
        var _max = _start.max;
        
        ___cave_value = (_system_length << 32) | (_max << 16) | _min;
        ___cave_start_amplitude = _max - _min;
        ___cave_start_octaves = _start.octaves;
        
        ___cave_system = array_create(_system_length);
        
        for (var i = 0; i < _system_length; ++i)
        {
            var _data = _system[i];
            
            var _range = _data.range;
            var _threshold = _data.threshold;
            
            ___cave_system[@ i] = {
                ___value: (_threshold.max << 40) | (_threshold.min << 32) | (_range.max << 16) | _range.min,
                ___octaves: _threshold.octaves
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
    
    static get_cave_start_amplitude = function()
    {
        return ___cave_start_amplitude;
    }
    
    static get_cave_system_length = function()
    {
        return (___cave_value >> 32) & 0xffff;
    }
    
    static get_cave_start_octaves = function()
    {
        return ___cave_start_octaves;
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
    
    static get_cave_system_threshold_octaves = function(_index)
    {
        return ___cave_system[_index].___octaves;
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