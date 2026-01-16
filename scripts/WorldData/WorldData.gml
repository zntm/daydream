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
        
        ___cave_biome_depth_zones = _cave_biome[$ "depth_zones"] ?? [];
        ___cave_biome_depth_zones_length = array_length(___cave_biome_depth_zones);
        
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
            
            if (___cave_biome_heat != undefined)
            {
                ___cave_heat_noise_scale_x = ___cave_biome_heat[$ "noise_scale_x"] ?? 0.015625;
                ___cave_heat_noise_scale_y = ___cave_biome_heat[$ "noise_scale_y"] ?? 0.015625;
                ___cave_heat_range = ___cave_biome_heat[$ "range"] ?? 63;
            }
            else
            {
                ___cave_heat_noise_scale_x = 0;
                ___cave_heat_noise_scale_y = 0;
                ___cave_heat_range = 0;
            }
            
            if (___cave_biome_humidity != undefined)
            {
                ___cave_humidity_noise_scale_x = ___cave_biome_humidity[$ "noise_scale_x"] ?? 0.015625;
                ___cave_humidity_noise_scale_y = ___cave_biome_humidity[$ "noise_scale_y"] ?? 0.015625;
                ___cave_humidity_offset_y = ___cave_biome_humidity[$ "offset_y"] ?? 1000;
                ___cave_humidity_range = ___cave_biome_humidity[$ "range"] ?? 63;
                ___cave_humidity_octaves_offset = ___cave_biome_humidity[$ "octaves_offset"] ?? 16;
            }
            else
            {
                ___cave_humidity_noise_scale_x = 0;
                ___cave_humidity_noise_scale_y = 0;
                ___cave_humidity_offset_y = 0;
                ___cave_humidity_range = 0;
                ___cave_humidity_octaves_offset = 0;
            }
            
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
    
    static get_cave_biome_depth_zones = function()
    {
        return ___cave_biome_depth_zones;
    }
    
    static get_cave_biome_depth_zones_length = function()
    {
        return ___cave_biome_depth_zones_length;
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
    
    static get_cave_heat_noise_scale_x = function() { return ___cave_heat_noise_scale_x; }
    static get_cave_heat_noise_scale_y = function() { return ___cave_heat_noise_scale_y; }
    static get_cave_heat_range = function() { return ___cave_heat_range; }
    
    static get_cave_humidity_noise_scale_x = function() { return ___cave_humidity_noise_scale_x; }
    static get_cave_humidity_noise_scale_y = function() { return ___cave_humidity_noise_scale_y; }
    static get_cave_humidity_offset_y = function() { return ___cave_humidity_offset_y; }
    static get_cave_humidity_range = function() { return ___cave_humidity_range; }
    static get_cave_humidity_octaves_offset = function() { return ___cave_humidity_octaves_offset; }
    
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
        __biome_map_buffer = -1;
        
        ___surface_biome_heat = _surface_biome.heat;
        ___surface_biome_humidity = _surface_biome.humidity;
        
        ___surface_heat_noise_scale = ___surface_biome_heat[$ "noise_scale"] ?? 0.015625;
        ___surface_heat_offset = ___surface_biome_heat[$ "offset"] ?? -16;
        ___surface_heat_range = ___surface_biome_heat[$ "range"] ?? 63;
        
        ___surface_humidity_noise_scale = ___surface_biome_humidity[$ "noise_scale"] ?? 0.015625;
        ___surface_humidity_offset = ___surface_biome_humidity[$ "offset"] ?? -24;
        ___surface_humidity_range = ___surface_biome_humidity[$ "range"] ?? 63;
        
        ___surface_heat_spline_x = ___surface_biome_heat[$ "spline_x"] == undefined ? undefined : ___surface_biome_heat.spline_x.points;
        ___surface_heat_spline_y = ___surface_biome_heat[$ "spline_y"] == undefined ? undefined : ___surface_biome_heat.spline_y.points;
        
        ___surface_humidity_spline_x = ___surface_biome_humidity[$ "spline_x"] == undefined ? undefined : ___surface_biome_humidity.spline_x.points;
        ___surface_humidity_spline_y = ___surface_biome_humidity[$ "spline_y"] == undefined ? undefined : ___surface_biome_humidity.spline_y.points;
        
        ___surface_biome_transitions = _surface_biome[$ "transitions"]; // Load transitions rules array
        
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
    
    static get_surface_biome_transitions = function()
    {
        return ___surface_biome_transitions;
    }
    
    static get_surface_heat_noise_scale = function() { return ___surface_heat_noise_scale; }
    static get_surface_heat_offset = function() { return ___surface_heat_offset; }
    static get_surface_heat_range = function() { return ___surface_heat_range; }
    
    static get_surface_humidity_noise_scale = function() { return ___surface_humidity_noise_scale; }
    static get_surface_humidity_offset = function() { return ___surface_humidity_offset; }
    static get_surface_humidity_range = function() { return ___surface_humidity_range; }
    
    static get_surface_heat_spline_x = function() { return ___surface_heat_spline_x; }
    static get_surface_heat_spline_y = function() { return ___surface_heat_spline_y; }
    
    static get_surface_humidity_spline_x = function() { return ___surface_humidity_spline_x; }
    static get_surface_humidity_spline_y = function() { return ___surface_humidity_spline_y; }
    
    static set_surface = function(_surface)
    {
        ___surface_start = _surface.start;
        
        var _noise_offset = _surface.noise_offset;
        ___surface_noise_offset_max = _noise_offset.max;
        ___surface_noise_offset_min = _noise_offset.min;
        ___surface_noise_offset_octaves = _noise_offset.octaves;
        ___surface_noise_offset_scale = _noise_offset[$ "scale"] ?? 0.015625;
        ___surface_noise_offset_y = _noise_offset[$ "y_offset"] ?? -48;
        
        var _smoothing = _surface[$ "smoothing"];
        ___surface_smoothing_range = _smoothing[$ "range"] ?? 32;
        ___surface_smoothing_factor = _smoothing[$ "factor"] ?? 0.6;
        
        ___surface_noise_scale = _surface[$ "noise_scale"] ?? 0.015625;
        ___surface_seed_offset = _surface[$ "seed_offset"] ?? -40;
        ___surface_min_depth = _surface[$ "min_depth"] ?? 8;
        
        ___bedrock_depth = _surface[$ "bedrock_depth"] ?? 3;
        ___bedrock_noise_scale = _surface[$ "bedrock_noise_scale"] ?? 0.3;
        ___tile_variation_noise_scale = _surface[$ "tile_variation_noise_scale"] ?? 0.05;
        ___biome_blend_range = _surface[$ "biome_blend_range"] ?? 24;
        ___biome_blend_noise_scale = _surface[$ "biome_blend_noise_scale"] ?? 0.08;
        
        return self;
    }
    
    /// @desc Set terrain shaping parameters for 3D noise-based terrain
    static set_terrain_shaping = function(_config)
    {
        // Squash factor compresses Y for horizontal caves/overhangs (> 1 = flatter/wider)
        ___terrain_squash_factor = _config[$ "squash_factor"] ?? 4.0; // Flatter, wider plates
        
        // 3D density noise settings
        ___terrain_3d_noise_scale = _config[$ "noise_scale_3d"] ?? 0.015; // Larger features
        ___terrain_density_threshold = _config[$ "density_threshold"] ?? 0.0;
        
        // Z-offset for walls (higher = walls extend further than solid)
        ___terrain_z_offset_wall = _config[$ "z_offset_wall"] ?? 0.075; // More connected look as requested
        
        // Z-range for walls (sampling range around offset for thickness)
        ___terrain_z_range_wall = _config[$ "z_range_wall"] ?? 0.05;
        
        // Z-offset for material variation (sedimentary layers, gravel patches, etc.)
        ___terrain_z_offset_material = _config[$ "z_offset_material"] ?? 0.5;
        
        // Continentalness (large-scale surface variation)
        ___terrain_continentalness_scale = _config[$ "continentalness_scale"] ?? 0.0015;
        ___terrain_continentalness_amplitude = _config[$ "continentalness_amplitude"] ?? 180;
        
        // Peaks/Valleys (local height variation)
        ___terrain_peaks_scale = _config[$ "peaks_scale"] ?? 0.04;
        ___terrain_peaks_amplitude = _config[$ "peaks_amplitude"] ?? 100;
        
        // Erosion (controls cave/overhang intensity variation)
        ___terrain_erosion_scale = _config[$ "erosion_scale"] ?? 0.015;
        
        return self;
    }
    
    static get_terrain_squash_factor = function() { return self[$ "___terrain_squash_factor"] ?? 0.5; }
    static get_terrain_3d_noise_scale = function() { return self[$ "___terrain_3d_noise_scale"] ?? 0.04; }
    static get_terrain_density_threshold = function() { return self[$ "___terrain_density_threshold"] ?? 0.0; }
    static get_terrain_z_offset_wall = function() { return self[$ "___terrain_z_offset_wall"] ?? 0.15; }
    static get_terrain_z_range_wall = function() { return self[$ "___terrain_z_range_wall"] ?? 0.01; }
    static get_terrain_z_offset_material = function() { return self[$ "___terrain_z_offset_material"] ?? 0.5; }
    static get_terrain_continentalness_scale = function() { return self[$ "___terrain_continentalness_scale"] ?? 0.003; }
    static get_terrain_continentalness_amplitude = function() { return self[$ "___terrain_continentalness_amplitude"] ?? 80; }
    static get_terrain_peaks_scale = function() { return self[$ "___terrain_peaks_scale"] ?? 0.02; }
    static get_terrain_peaks_amplitude = function() { return self[$ "___terrain_peaks_amplitude"] ?? 25; }
    static get_terrain_erosion_scale = function() { return self[$ "___terrain_erosion_scale"] ?? 0.015; }
    
    // --- NEW WORLDGEN SPLINE GETTERS ---
    // These read from the worldgen section of the JSON config
    
    static get_worldgen_erosion_scale = function() { return self[$ "___worldgen_erosion_scale"] ?? 0.008; }
    static get_worldgen_continentalness_scale = function() { return self[$ "___worldgen_continentalness_scale"] ?? 0.001; }
    static get_worldgen_continentalness_amplitude = function() { return self[$ "___worldgen_continentalness_amplitude"] ?? 150; }
    static get_worldgen_cave_noise_scale = function() { return self[$ "___worldgen_cave_noise_scale"] ?? 0.015; }
    
    static get_worldgen_squash_spline = function() { return self[$ "___worldgen_squash_spline"]; }
    static get_worldgen_cave_noise_range_spline = function() { return self[$ "___worldgen_cave_noise_range_spline"]; }
    static get_worldgen_cave_density_spline = function() { return self[$ "___worldgen_cave_density_spline"]; }
    static get_worldgen_cave_smoothness_spline = function() { return self[$ "___worldgen_cave_smoothness_spline"]; }
    
    /// @desc Set worldgen config (new unified system)
    static set_worldgen = function(_config)
    {
        if (_config == undefined) return self;
        
        // Surface shape
        ___worldgen_erosion_scale = _config[$ "erosion_scale"] ?? 0.008;
        ___worldgen_continentalness_scale = _config[$ "continentalness_scale"] ?? 0.001;
        ___worldgen_continentalness_amplitude = _config[$ "continentalness_amplitude"] ?? 150;
        ___worldgen_squash_spline = _config[$ "squash_spline"];
        
        // Cave shape
        ___worldgen_cave_noise_scale = _config[$ "cave_noise_scale"] ?? 0.015;
        ___worldgen_cave_noise_range_spline = _config[$ "cave_noise_range_spline"];
        ___worldgen_cave_density_spline = _config[$ "cave_density_spline"];
        ___worldgen_cave_smoothness_spline = _config[$ "cave_smoothness_spline"];
        
        return self;
    }
    
    /// @desc Get terrain shaping configuration struct
    static get_terrain_shaping_config = function()
    {
        return {
            squash_factor: get_terrain_squash_factor(),
            noise_scale_3d: get_terrain_3d_noise_scale(),
            density_threshold: get_terrain_density_threshold(),
            z_offset_wall: get_terrain_z_offset_wall(),
            z_range_wall: get_terrain_z_range_wall(),
            z_offset_material: get_terrain_z_offset_material(),
            continentalness_scale: get_terrain_continentalness_scale(),
            continentalness_amplitude: get_terrain_continentalness_amplitude(),
            peaks_scale: get_terrain_peaks_scale(),
            peaks_amplitude: get_terrain_peaks_amplitude(),
            erosion_scale: get_terrain_erosion_scale()
        };
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

    static get_surface_noise_offset_scale = function()
    {
        return ___surface_noise_offset_scale;
    }

    static get_surface_noise_offset_y = function()
    {
        return ___surface_noise_offset_y;
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
                ___aquifers[i].edge_width ??= 10; // Default edge width in noise units
                // edge_tile can be undefined (no edge generation)
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
        ___cave_transition_noise_range = _cave[$ "transition_noise_range"] ?? 255;
        ___cave_transition_noise_octaves = _cave[$ "transition_noise_octaves"] ?? 3;
        
        ___cave_overhang_threshold = _cave[$ "overhang_threshold"];
        ___cave_overhang_threshold_tile = _cave[$ "overhang_threshold_tile"];
        ___cave_overhang_noise_scale = _cave[$ "overhang_noise_scale"] ?? 0.05;
        
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

    static get_cave_overhang_threshold = function()
    {
        return self[$ "___cave_overhang_threshold"];
    }

    static get_cave_overhang_threshold_tile = function()
    {
        return self[$ "___cave_overhang_threshold_tile"];
    }

    static get_cave_overhang_noise_scale = function()
    {
        return self[$ "___cave_overhang_noise_scale"];
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
    

}