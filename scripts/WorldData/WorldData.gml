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
    
    static set_cave = function(_cave)
    {
        var _start = _cave.start;
        ___cave_start_max = _start.max;
        ___cave_start_min = _start.min;
        ___cave_start_octaves = _start.octaves;
        ___cave_start_noise_scale = _start[$ "noise_scale"] ?? 0.015625;
        ___cave_start_offset = _start[$ "offset"] ?? -8;
        
        ___cave_system = _cave.system;
        ___cave_system_length = array_length(___cave_system);
        
        var _aquifers = _cave[$ "aquifers"];
        if (_aquifers != undefined)
        {
            ___aquifers = _aquifers;
            ___aquifers_length = array_length(_aquifers);
            
            // Inject defaults
            for (var i = 0; i < ___aquifers_length; ++i)
            {
                ___aquifers[i].noise_scale ??= 0.02;
                ___aquifers[i].range ??= 255;
            }
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
        
        ___cave_breach_noise_scale_x = _cave[$ "breach_noise_scale_x"] ?? 0.03;
        ___cave_breach_noise_scale_y = _cave[$ "breach_noise_scale_y"] ?? 0.03;
        ___cave_breach_noise_offset_y = _cave[$ "breach_noise_offset_y"] ?? 1000;
        ___cave_breach_noise_range = _cave[$ "breach_noise_range"] ?? 255;
        ___cave_breach_noise_octaves = _cave[$ "breach_noise_octaves"] ?? 2;
        
        ___cave_transition_noise_scale_x = _cave[$ "transition_noise_scale_x"] ?? 0.02;
        ___cave_transition_noise_scale_y = _cave[$ "transition_noise_scale_y"] ?? 0.02;
        ___cave_transition_noise_range = _cave[$ "transition_noise_range"] ?? 255;
        ___cave_transition_noise_octaves = _cave[$ "transition_noise_octaves"] ?? 3;
        
        // Depth smoothing spline for cave size
        var _depth_smoothing = _cave[$ "depth_smoothing"];
        if (_depth_smoothing != undefined)
        {
            ___cave_depth_smoothing = _depth_smoothing.points;
        }
        else
        {
            // Default: full caves everywhere (no depth smoothing)
            ___cave_depth_smoothing = [{ position: 0, value: 1 }];
        }
        
        return self;
    }

    static get_cave_breach_noise_scale_x = function()
    {
        return ___cave_breach_noise_scale_x;
    }

    static get_cave_breach_noise_scale_y = function()
    {
        return ___cave_breach_noise_scale_y;
    }

    static get_cave_breach_noise_offset_y = function()
    {
        return ___cave_breach_noise_offset_y;
    }

    static get_cave_breach_noise_range = function()
    {
        return ___cave_breach_noise_range;
    }

    static get_cave_breach_noise_octaves = function()
    {
        return ___cave_breach_noise_octaves;
    }

    static get_cave_transition_noise_scale_x = function()
    {
        return ___cave_transition_noise_scale_x;
    }

    static get_cave_transition_noise_scale_y = function()
    {
        return ___cave_transition_noise_scale_y;
    }

    static get_cave_transition_noise_range = function()
    {
        return ___cave_transition_noise_range;
    }

    static get_cave_transition_noise_octaves = function()
    {
        return ___cave_transition_noise_octaves;
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

    static get_cave_start_noise_scale = function()
    {
        return ___cave_start_noise_scale;
    }

    static get_cave_start_offset = function()
    {
        return ___cave_start_offset;
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
    
    static get_cave_depth_smoothing = function()
    {
        return ___cave_depth_smoothing;
    }
    
    static set_surface_settings = function(_surface)
    {
        ___surface_seed_offset = _surface[$ "seed_offset"] ?? -40;
        ___surface_start = _surface[$ "start"] ?? 512;
        ___surface_min_depth = _surface[$ "min_depth"] ?? 8;
        
        ___surface_noise_offset = _surface[$ "noise_offset"];
        ___surface_noise_scale = _surface[$ "noise_scale"] ?? 0.015625;
        
        ___bedrock_depth = _surface[$ "bedrock_depth"] ?? 3;
        ___bedrock_noise_scale = _surface[$ "bedrock_noise_scale"] ?? 0.3;
        
        ___tile_variation_noise_scale = _surface[$ "tile_variation_noise_scale"] ?? 0.05;
        
        ___biome_blend_range = _surface[$ "biome_blend_range"] ?? 24;
        ___biome_blend_noise_scale = _surface[$ "biome_blend_noise_scale"] ?? 0.08;
        
        return self;
    }

    static get_surface_start = function()
    {
        return ___surface_start;
    }

    static get_surface_noise_offset = function()
    {
        return ___surface_noise_offset;
    }

    static get_surface_noise_offset_octaves = function()
    {
        return ___surface_noise_offset[$ "octaves"] ?? 4;
    }
    
    static get_surface_noise_offset_min = function()
    {
        return ___surface_noise_offset[$ "min"] ?? 40;
    }

    static get_surface_noise_offset_max = function()
    {
        return ___surface_noise_offset[$ "max"] ?? 96;
    }

    static get_surface_noise_scale = function()
    {
        return ___surface_noise_scale;
    }

    static get_surface_noise_offset_scale = function()
    {
        return ___surface_noise_scale;
    }

    static get_surface_noise_offset_y = function()
    {
        return ___surface_seed_offset;
    }

    static get_surface_seed_offset = function()
    {
        return ___surface_seed_offset;
    }
    
    static get_surface_min_depth = function()
    {
        return ___surface_min_depth;
    }

    static get_bedrock_depth = function()
    {
        return ___bedrock_depth;
    }

    static get_bedrock_noise_scale = function()
    {
        return ___bedrock_noise_scale;
    }

    static get_tile_variation_noise_scale = function()
    {
        return ___tile_variation_noise_scale;
    }
    
    static get_biome_blend_range = function()
    {
        return ___biome_blend_range;
    }

    static get_biome_blend_noise_scale = function()
    {
        return ___biome_blend_noise_scale;
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
        
        ___sky_region_offset_y = _sky_biome[$ "region_offset_y"] ?? 1000;
        ___sky_region_range = _sky_biome[$ "region_range"] ?? 255;
        ___sky_region_octaves = _sky_biome[$ "region_octaves"] ?? 2;
        ___sky_region_threshold = _sky_biome[$ "region_threshold"] ?? 60;
        
        ___sky_edge_noise_amplitude = _sky_biome[$ "edge_noise_amplitude"] ?? 0.5;
        ___sky_edge_noise_octaves = _sky_biome[$ "edge_noise_octaves"] ?? 3;
        
        ___sky_detail_noise_amplitude = _sky_biome[$ "detail_noise_amplitude"] ?? 0.25;
        ___sky_detail_noise_octaves = _sky_biome[$ "detail_noise_octaves"] ?? 2;
        
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

    static get_sky_region_offset_y = function()
    {
        return ___sky_region_offset_y;
    }

    static get_sky_region_range = function()
    {
        return ___sky_region_range;
    }

    static get_sky_region_octaves = function()
    {
        return ___sky_region_octaves;
    }

    static get_sky_region_threshold = function()
    {
        return ___sky_region_threshold;
    }

    static get_sky_edge_noise_amplitude = function()
    {
        return ___sky_edge_noise_amplitude;
    }

    static get_sky_edge_noise_octaves = function()
    {
        return ___sky_edge_noise_octaves;
    }

    static get_sky_detail_noise_amplitude = function()
    {
        return ___sky_detail_noise_amplitude;
    }

    static get_sky_detail_noise_octaves = function()
    {
        return ___sky_detail_noise_octaves;
    }
    
    // --- Region Transition Settings ---
    
    static set_region_transition = function(_config)
    {
        ___region_transition_width = _config[$ "width"] ?? 32;
        ___region_transition_noise_scale = _config[$ "noise_scale"] ?? 0.05;
        ___region_transition_noise_amplitude = _config[$ "noise_amplitude"] ?? 8;
        
        return self;
    }
    
    static get_region_transition_width = function()
    {
        return self[$ "___region_transition_width"] ?? 32;
    }
    
    static get_region_transition_noise_scale = function()
    {
        return self[$ "___region_transition_noise_scale"] ?? 0.05;
    }
    
    static get_region_transition_noise_amplitude = function()
    {
        return self[$ "___region_transition_noise_amplitude"] ?? 8;
    }
    
    // --- Surface Biome Data ---
    
    static set_surface_biome_data = function(_surface)
    {
        ___surface_biome_heat = _surface.heat;
        ___surface_biome_humidity = _surface.humidity;
        
        var _map = _surface[$ "map"];
        
        if (is_string(_map))
        {
            show_debug_message($"[WorldData] Warning: Biome map '{_map}' is a string. Using default 'phantasia:surface/greenia'.");
            
            // Default 64x64 map (4096 size)
            var _size = 4096; 
            _map = array_create(_size, "phantasia:surface/greenia");
        }
        
        ___surface_biome_map = _map;
        ___surface_biome_offset = _surface.offset;
        
        return self;
    }
    
    static get_surface_biome_heat = function()
    {
        return ___surface_biome_heat;
    }
    
    static get_surface_heat_noise_scale = function()
    {
        return ___surface_biome_heat[$ "scale"] ?? 0.015625;
    }
    
    static get_surface_heat_offset = function()
    {
        return ___surface_biome_heat[$ "offset"] ?? 0;
    }
    
    static get_surface_heat_range = function()
    {
        return ___surface_biome_heat[$ "range"] ?? 255;
    }
    
    static get_surface_heat_spline_x = function()
    {
        var _spline = ___surface_biome_heat[$ "spline_x"];
        if (_spline != undefined) return _spline.points;
        return undefined;
    }

    static get_surface_heat_spline_y = function()
    {
        var _spline = ___surface_biome_heat[$ "spline_y"];
        if (_spline != undefined) return _spline.points;
        return undefined;
    }
    
    static get_surface_biome_humidity = function()
    {
        return ___surface_biome_humidity;
    }
    
    static get_surface_humidity_noise_scale = function()
    {
        return ___surface_biome_humidity[$ "scale"] ?? 0.015625;
    }
    
    static get_surface_humidity_offset = function()
    {
        return ___surface_biome_humidity[$ "offset"] ?? 0;
    }
    
    static get_surface_humidity_range = function()
    {
        return ___surface_biome_humidity[$ "range"] ?? 255;
    }
    
    static get_surface_humidity_spline_x = function()
    {
        var _spline = ___surface_biome_humidity[$ "spline_x"];
        if (_spline != undefined) return _spline.points;
        return undefined;
    }

    static get_surface_humidity_spline_y = function()
    {
        var _spline = ___surface_biome_humidity[$ "spline_y"];
        if (_spline != undefined) return _spline.points;
        return undefined;
    }
    
    static get_surface_biome_offset = function()
    {
        return ___surface_biome_offset;
    }
    
    // --- Cave Biome Data ---
    
    static set_cave_biome_data = function(_cave)
    {
        ___cave_biome_default = _cave[$ "default"] ?? [];
        ___cave_biome_default_length = array_length(___cave_biome_default);
        
        ___cave_biome_heat = _cave[$ "heat"] ?? { octaves: 4 };
        ___cave_biome_humidity = _cave[$ "humidity"] ?? { octaves: 4 };
        
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
    
    static get_cave_biome_heat = function()
    {
        return ___cave_biome_heat;
    }
    
    static get_cave_heat_noise_scale_x = function()
    {
        return ___cave_biome_heat[$ "noise_scale_x"] ?? ___cave_biome_heat[$ "scale"] ?? 0.005;
    }
    
    static get_cave_heat_noise_scale_y = function()
    {
        return ___cave_biome_heat[$ "noise_scale_y"] ?? ___cave_biome_heat[$ "scale"] ?? 0.005;
    }
    
    static get_cave_heat_range = function()
    {
        return ___cave_biome_heat[$ "range"] ?? 255;
    }
    
    static get_cave_biome_humidity = function()
    {
        return ___cave_biome_humidity;
    }
    
    static get_cave_humidity_noise_scale_x = function()
    {
        return ___cave_biome_humidity[$ "noise_scale_x"] ?? ___cave_biome_humidity[$ "scale"] ?? 0.005;
    }
    
    static get_cave_humidity_noise_scale_y = function()
    {
        return ___cave_biome_humidity[$ "noise_scale_y"] ?? ___cave_biome_humidity[$ "scale"] ?? 0.005;
    }
    
    static get_cave_humidity_offset_y = function()
    {
        return ___cave_biome_humidity[$ "y_offset"] ?? 0;
    }
    
    static get_cave_humidity_range = function()
    {
        return ___cave_biome_humidity[$ "range"] ?? 255;
    }
    
    static get_cave_humidity_octaves_offset = function()
    {
        return ___cave_biome_humidity[$ "octaves_offset"] ?? 0;
    }
}