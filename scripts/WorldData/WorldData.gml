function WorldCelestial(_id, _time_range_min, _time_range_max) constructor
{
    ___id = _id;
    ___time_range_min = _time_range_min;
    ___time_range_max = _time_range_max;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_time_range_min = function()
    {
        return ___time_range_min;
    }
    
    static get_time_range_max = function()
    {
        return ___time_range_max;
    }
}

function WorldData(_namespace, _id, _world_height) : ParentData(_namespace, _id) constructor
{
    ___world_height = _world_height;
    
    static get_world_height = function()
    {
        return ___world_height;
    }
    
    static set_spawn_interval = function(_interval)
    {
        ___spawn_interval = _interval;
        
        return self;
    }
    
    static get_spawn_interval = function()
    {
        return ___spawn_interval;
    }
    
    static set_vignette = function(_ystart, _yend, _colour)
    {
        ___vignette_ystart = _ystart;
        ___vignette_yend = _yend;
        ___vignette_colour = _colour;
        
        return self;
    }
    
    static get_vignette_ystart = function()
    {
        return ___vignette_ystart;
    }
    
    static get_vignette_yend = function()
    {
        return ___vignette_yend;
    }
    
    static get_vignette_colour = function()
    {
        return ___vignette_colour;
    }
    
    static set_time = function(_time)
    {
        ___time_start = _time.start;
        
        ___time_diurnal = _time.diurnal;
        ___time_diurnal_length = array_length(___time_diurnal);
        
        ___time_length = _time.length;
        
        return self;
    }
    
    static get_time_start = function()
    {
        return ___time_start;
    }
    
    static get_time_diurnal = function()
    {
        return ___time_diurnal;
    }
    
    static get_time_diurnal_length = function()
    {
        return ___time_diurnal_length;
    }
    
    static get_time_length = function()
    {
        return ___time_length;
    }
    
    static set_celestials = function(_celestial)
    {
        ___celestial = _celestial;
        ___celestial_length = array_length(_celestial);
        
        return self;
    }
    
    static get_celestials = function()
    {
        return ___celestial;
    }
    
    static get_celestials_length = function()
    {
        return ___celestial_length;
    }
    
    static set_cave_biome = function(_cave_biome)
    {
        ___cave_biome_default = _cave_biome[$ "default"];
        ___cave_biome_default_length = array_length(___cave_biome_default);
        
        var _map = _cave_biome[$ "map"];
        
        if (_map != undefined)
        {
            static __biome_map_buffer_cave  = -1;
            static __biome_map_surface_cave = -1;
            
            if (!buffer_exists(__biome_map_buffer_cave))
            {
                __biome_map_buffer_cave = buffer_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT * 4, buffer_fixed, 1);
            }
            
            if (!surface_exists(__biome_map_surface_cave))
            {
                __biome_map_surface_cave = surface_create(WORLDGEN_SIZE_HUMIDITY, WORLDGEN_SIZE_HEAT);
            }
            
            ___cave_biome_map_id = _map;
            
            var _sprite = global.sprite_asset[$ _map].get_sprite();
            
            surface_set_target(__biome_map_surface_cave);
            
            draw_sprite(_sprite, 0, 0, 0);
            
            surface_reset_target();
            
            buffer_get_surface(__biome_map_buffer_cave, __biome_map_surface_cave, 0);
            
            surface_free(__biome_map_surface_cave);
            __biome_map_surface_cave = -1;
            
            var _biome_data = global.biome_data;
            
            var _names = struct_get_names(_biome_data);
            var _length = array_length(_names);
            
            var _cave_biome_map = array_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT, 0);
            
            for (var j = 0; j < _length; ++j)
            {
                var _name = _names[j];
                
                var _map_colour = _biome_data[$ _name].get_map_colour();
                
                if (_map_colour == undefined) continue;
                
                buffer_seek(__biome_map_buffer_cave, buffer_seek_start, 0);
                
                for (var l = 0; l < WORLDGEN_SIZE_HUMIDITY; ++l)
                {
                    var _index_humidity = l << WORLDGEN_SIZE_HEAT_BIT;
                    
                    for (var m = 0; m < WORLDGEN_SIZE_HEAT; ++m)
                    {
                        var _colour = buffer_read(__biome_map_buffer_cave, buffer_u32) & 0xffffff;
                        
                        if (_map_colour == _colour)
                        {
                            _cave_biome_map[@ _index_humidity | m] = _name;
                        }
                    }
                }
            }
            
            buffer_delete(__biome_map_buffer_cave);
            __biome_map_buffer_cave = -1; // Reset since we delete it
            
            ___cave_biome_heat = _cave_biome.heat;
            ___cave_biome_humidity = _cave_biome.humidity;
            
            set_cave_biome_map(_cave_biome_map);
        }
        
        return self;
    }
    
    static get_cave_biome_default = function()
    {
        return ___cave_biome_default;
    }
    
    static get_cave_biome_default_length = function()
    {
        return ___cave_biome_default_length;
    }
    
    static set_cave_biome_map = function(_map)
    {
        ___cave_biome_map = _map;
        
        return self;
    }
    
    static get_cave_biome_map = function()
    {
        return self[$ "___cave_biome_map"];
    }
    
    static get_cave_biome_heat = function()
    {
        return self[$ "___cave_biome_heat"];
    }
    
    static get_cave_biome_humidity = function()
    {
        return self[$ "___cave_biome_humidity"];
    }
    
    static set_surface_biome = function(_surface_biome)
    {
        static __biome_map_buffer  = -1;
        static __biome_map_surface = -1;
        
        if (!buffer_exists(__biome_map_buffer))
        {
            __biome_map_buffer = buffer_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT * 4, buffer_fixed, 1);
        }
        
        if (!surface_exists(__biome_map_surface))
        {
            __biome_map_surface = surface_create(WORLDGEN_SIZE_HUMIDITY, WORLDGEN_SIZE_HEAT);
        }
        
        ___surface_biome = _surface_biome;
        
        var _sprite = global.sprite_asset[$ _surface_biome.map].get_sprite();
        
        surface_set_target(__biome_map_surface);
        
        draw_sprite(_sprite, 0, 0, 0);
        
        surface_reset_target();
        
        buffer_get_surface(__biome_map_buffer, __biome_map_surface, 0);
        
        surface_free(__biome_map_surface);
        __biome_map_surface = -1;
        
        var _biome_data = global.biome_data;
        
        var _names = struct_get_names(_biome_data);
        var _length = array_length(_names);
        
        var _surface_biome_map = array_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT, 0);
        
        for (var j = 0; j < _length; ++j)
        {
            var _name = _names[j];
            
            var _map_colour = _biome_data[$ _name].get_map_colour();
            
            if (_map_colour == undefined) continue;
            
            buffer_seek(__biome_map_buffer, buffer_seek_start, 0);
            
            for (var l = 0; l < WORLDGEN_SIZE_HUMIDITY; ++l)
            {
                var _index_humidity = l << WORLDGEN_SIZE_HEAT_BIT;
                
                for (var m = 0; m < WORLDGEN_SIZE_HEAT; ++m)
                {
                    var _colour = buffer_read(__biome_map_buffer, buffer_u32) & 0xffffff;
                    
                    if (_map_colour == _colour)
                    {
                        _surface_biome_map[@ _index_humidity | m] = _name;
                    }
                }
            }
        }
        
        buffer_delete(__biome_map_buffer);
        
        ___surface_biome_heat = _surface_biome.heat;
        ___surface_biome_humidity = _surface_biome.humidity;
        
        set_surface_biome_map(_surface_biome_map);
        
        return self;
    }
    
    static get_surface_biome = function()
    {
        return ___surface_biome;
    }
    
    static get_surface_biome_heat = function()
    {
        return ___surface_biome_heat;
    }
    
    static get_surface_biome_humidity = function()
    {
        return ___surface_biome_humidity;
    }
    
    static set_surface = function(_surface)
    {
        ___surface_start = _surface.start;
        
        var _noise_offset = _surface.noise_offset;
        ___surface_noise_offset_max = _noise_offset.max;
        ___surface_noise_offset_min = _noise_offset.min;
        ___surface_noise_offset_octaves = _noise_offset.octaves;
        
        var _smoothing = _surface[$ "smoothing"];
        ___surface_smoothing_range = _smoothing[$ "range"] ?? 32;
        ___surface_smoothing_factor = _smoothing[$ "factor"] ?? 0.6;
        
        ___surface_noise_scale = _surface[$ "noise_scale"] ?? 0.015625;
        
        return self;
    }
    
    static get_surface_start = function()
    {
        return ___surface_start;
    }
    
    static get_surface_noise_offset_max = function()
    {
        return ___surface_noise_offset_max;
    }
    
    static get_surface_noise_offset_min = function()
    {
        return ___surface_noise_offset_min;
    }
    
    static get_surface_noise_offset_octaves = function()
    {
        return ___surface_noise_offset_octaves;
    }
    
    static get_surface_smoothing_range = function()
    {
        return ___surface_smoothing_range;
    }
    
    static get_surface_smoothing_factor = function()
    {
        return ___surface_smoothing_factor;
    }
    
    static get_surface_noise_scale = function()
    {
        return ___surface_noise_scale;
    }
    
    static set_cave = function(_cave)
    {
        var _start = _cave.start;
        ___cave_start_max = _start.max;
        ___cave_start_min = _start.min;
        ___cave_start_octaves = _start.octaves;
        
        ___cave_system = _cave.system;
        ___cave_system_length = array_length(___cave_system);
        
        var _aquifers = _cave[$ "aquifers"];
        if (_aquifers != undefined)
        {
            ___aquifers = _aquifers;
            ___aquifers_length = array_length(_aquifers);
        }
        else
        {
            ___aquifers = [];
            ___aquifers_length = 0;
        }
        
        ___cave_noise_scale = _cave[$ "noise_scale"] ?? 0.015625;
        ___cave_breach_threshold = _cave[$ "breach_threshold"] ?? 242;
        ___cave_breach_depth = _cave[$ "breach_depth"] ?? -8;
        ___cave_transition_threshold = _cave[$ "transition_threshold"] ?? 220;
        
        return self;
    }
    
    static get_aquifers = function()
    {
        return self[$ "___aquifers"] ?? [];
    }
    
    static get_aquifers_length = function()
    {
        return self[$ "___aquifers_length"] ?? 0;
    }
    
    static get_cave_start_max = function()
    {
        return ___cave_start_max;
    }
    
    static get_cave_start_min = function()
    {
        return ___cave_start_min;
    }
    
    static get_cave_start_octaves = function()
    {
        return ___cave_start_octaves;
    }
    
    static get_cave_system = function()
    {
        return ___cave_system;
    }
    
    static get_cave_system_length = function()
    {
        return ___cave_system_length;
    }

    static get_cave_noise_scale = function()
    {
        return ___cave_noise_scale;
    }

    static get_cave_breach_threshold = function()
    {
        return ___cave_breach_threshold;
    }

    static get_cave_breach_depth = function()
    {
        return ___cave_breach_depth;
    }

    static get_cave_transition_threshold = function()
    {
        return ___cave_transition_threshold;
    }
    
    static set_surface_biome_map = function(_map)
    {
        ___surface_biome_map = _map;
        
        return self;
    }
    
    static get_surface_biome_map = function()
    {
        return ___surface_biome_map;
    }
    
    static set_sky_biome = function(_sky_biome)
    {
        ___sky_biome_threshold = _sky_biome[$ "threshold"] ?? 256;
        ___sky_biome_id = _sky_biome[$ "id"] ?? "phantasia:sky/floating_islands";
        ___sky_biome_enabled = _sky_biome[$ "enabled"] ?? true;
        
        ___sky_island_spacing = _sky_biome[$ "spacing"] ?? 32;
        ___sky_island_radius = _sky_biome[$ "radius"] ?? 18;
        ___sky_island_thickness = _sky_biome[$ "thickness"] ?? 10;
        ___sky_noise_scale_region = _sky_biome[$ "noise_scale_region"] ?? 0.12;
        ___sky_noise_scale_edge = _sky_biome[$ "noise_scale_edge"] ?? 0.15;
        ___sky_noise_scale_detail = _sky_biome[$ "noise_scale_detail"] ?? 0.3;
        
        return self;
    }
    
    static get_sky_biome_threshold = function()
    {
        return self[$ "___sky_biome_threshold"] ?? 256;
    }
    
    static get_sky_biome_id = function()
    {
        return self[$ "___sky_biome_id"] ?? "phantasia:sky/floating_islands";
    }
    
    static is_sky_biome_enabled = function()
    {
        return self[$ "___sky_biome_enabled"] ?? true;
    }
    
    static get_sky_island_spacing = function()
    {
        return ___sky_island_spacing;
    }
    
    static get_sky_island_radius = function()
    {
        return ___sky_island_radius;
    }
    
    static get_sky_island_thickness = function()
    {
        return ___sky_island_thickness;
    }
    
    static get_sky_noise_scale_region = function()
    {
        return ___sky_noise_scale_region;
    }
    
    static get_sky_noise_scale_edge = function()
    {
        return ___sky_noise_scale_edge;
    }
    
    static get_sky_noise_scale_detail = function()
    {
        return ___sky_noise_scale_detail;
    }
}