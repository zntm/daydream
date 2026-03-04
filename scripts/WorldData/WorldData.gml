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
    ___region_generator = undefined;
    ___regions_ids = undefined;
    ___regions_objects = undefined;
    ___biome_transition_smoothing = 0.5;
    ___surface_biome = undefined;
    ___cave_biome = undefined;
    ___sky_biome = undefined;
    ___surface_start = 0;
    ___spawn_interval = 2.0;
    ___vignette_ystart = 0;
    ___vignette_yend = 0;
    ___vignette_colour = c_black;
    ___time_start = 0;
    ___time_length = 1200;
    ___celestial = [];
    ___celestial_length = 0;
    
    // Background (clouds, celestials, parallax)
    ___background_script = undefined;
    ___background_sprites = [];
    ___background_parallax_factor = 0.005;
    ___background_parallax_scale = 1;
    ___background_cloud_count = 8;
    ___background_cloud_y_min = 16;
    ___background_cloud_y_max = 80;
    ___background_cloud_scale_min = 1.2;
    ___background_cloud_scale_max = 2.0;
    ___background_cloud_alpha_min = 0.3;
    ___background_cloud_alpha_max = 0.7;
    ___background_cloud_speed_min = 1;
    ___background_cloud_speed_max = 4;
    ___background_cloud_wind_factor = 0.5;
    
    // Colorgrade
    ___colorgrade_saturation    = 1;
    ___colorgrade_tint_r        = 1;
    ___colorgrade_tint_g        = 1;
    ___colorgrade_tint_b        = 1;
    ___colorgrade_tint_strength = 0;
    
    // Surface Generation
    ___surface_noise_offset_max = 0;
    ___surface_noise_offset_min = 0;
    ___surface_noise_offset_octaves = 1;
    ___surface_noise_offset_scale = 0.01;
    ___surface_noise_offset_y = 0;
    ___surface_smoothing_range = 32;
    ___surface_smoothing_factor = 0.6;
    ___surface_noise_scale = 0.01;
    ___surface_seed_offset = 0;
    ___surface_min_depth = 8;
    ___bedrock_depth = 3;
    ___bedrock_noise_scale = 0.3;
    ___tile_variation_noise_scale = 0.05;
    ___biome_blend_range = 24;
    ___biome_blend_noise_scale = 0.08;
    ___surface_biome_map = undefined;
    ___map_buffer = undefined;
    ___map_width = 0;
    ___map_height = 0;
    
    // Cave Generation
    ___cave_start_max = 0;
    ___cave_start_min = 0;
    ___cave_start_octaves = 1;
    ___cave_start_noise_scale = 0.01;
    ___cave_start_offset = 0;
    ___cave_system = [];
    ___cave_system_length = 0;
    ___aquifers = [];
    ___aquifers_length = 0;
    ___cave_noise_scale = 0.01;
    ___cave_breach_threshold = 242;
    ___cave_breach_depth = -8;
    ___cave_transition_threshold = 220;
    ___cave_breach_noise_scale_x = 0.03;
    ___cave_breach_noise_scale_y = 0.03;
    ___cave_breach_noise_offset_y = 1000;
    ___cave_breach_noise_range = 255;
    ___cave_breach_noise_octaves = 2;
    ___cave_transition_noise_scale_x = 0.02;
    ___cave_transition_noise_scale_y = 0.02;
    ___cave_transition_noise_range = 255;
    ___cave_transition_noise_octaves = 3;
    ___cave_depth_smoothing = [{ position: 0, value: 1 }];
    
    // Cave Biomes (Legacy/Fallback)
    ___cave_biome_default = [];
    ___cave_biome_default_length = 0;
    ___cave_biome_depth_zones = [];
    ___cave_biome_depth_zones_length = 0;
    ___cave_biome_map = undefined;
    ___cave_biome_heat = undefined;
    ___cave_biome_humidity = undefined;
    ___cave_heat_noise_scale_x = 0;
    ___cave_heat_noise_scale_y = 0;
    ___cave_heat_range = 0;
    ___cave_humidity_noise_scale_x = 0;
    ___cave_humidity_noise_scale_y = 0;
    ___cave_humidity_offset_y = 0;
    ___cave_humidity_range = 0;
    ___cave_humidity_octaves_offset = 0;
    
    // Climate Generation
    ___surface_heat_noise_scale = 0.005;
    ___surface_heat_noise_octaves = 4;
    ___surface_humidity_noise_scale = 0.005;
    ___surface_humidity_noise_octaves = 4;
    
    // Sky Biomes
    ___sky_biome_threshold = 256;
    ___sky_biome_id = "phantasia:sky/floating_islands";
    ___sky_biome_enabled = true;
    ___sky_island_spacing = 32;
    ___sky_island_radius = 18;
    ___sky_island_thickness = 10;
    ___sky_noise_scale_region = 0.12;
    ___sky_noise_scale_edge = 0.15;
    ___sky_noise_scale_detail = 0.3;
    ___sky_region_offset_y = 1000;
    ___sky_region_range = 255;
    ___sky_region_octaves = 2;
    ___sky_region_threshold = 60;
    ___sky_edge_noise_amplitude = 1;
    ___sky_edge_noise_octaves = 1;
    ___sky_detail_noise_amplitude = 1;
    ___sky_detail_noise_octaves = 1;
    
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
        ___vignette_colour = is_string(_colour) ? hex_parse(_colour) : _colour;
        
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
        
        
        ___time_length = _time.length;
        
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
        ___cave_biome = _cave_biome;
        
        // Note: Legacy cave biome map parsing removed.
        // Biome selection is now handled via Regions.
        
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
    
    // Climate Accessors
    static get_surface_heat_noise_scale = function() { return ___surface_heat_noise_scale; }
    static get_surface_heat_noise_octaves = function() { return ___surface_heat_noise_octaves; }
    static get_surface_humidity_noise_scale = function() { return ___surface_humidity_noise_scale; }
    static get_surface_humidity_noise_octaves = function() { return ___surface_humidity_noise_octaves; }
    
    static set_surface_biome = function(_surface_biome)
    {
        ___surface_biome = _surface_biome;
        
        // Parse heat/humidity configuration
        var _heat = _surface_biome[$ "heat"];
        if (_heat != undefined)
        {
            ___surface_heat_noise_scale = _heat[$ "scale"] ?? ___surface_heat_noise_scale;
            ___surface_heat_noise_octaves = _heat[$ "octaves"] ?? ___surface_heat_noise_octaves;
        }
        
        var _humidity = _surface_biome[$ "humidity"];
        if (_humidity != undefined)
        {
            ___surface_humidity_noise_scale = _humidity[$ "scale"] ?? ___surface_humidity_noise_scale;
            ___surface_humidity_noise_octaves = _humidity[$ "octaves"] ?? ___surface_humidity_noise_octaves;
        }
        
        return self;
    }
    
    static get_surface_biome = function()
    {
        return ___surface_biome;
    }
    
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
        
        
        ___surface_noise_scale = _surface[$ "noise_scale"] ?? _surface[$ "scale"] ?? 0.015625;
        ___surface_seed_offset = _surface[$ "seed_offset"] ?? -40;
        ___surface_min_depth = _surface[$ "min_depth"] ?? 8;
        
        ___bedrock_depth = _surface[$ "bedrock_depth"] ?? 3;
        ___bedrock_noise_scale = _surface[$ "bedrock_noise_scale"] ?? 0.3;
        ___tile_variation_noise_scale = _surface[$ "tile_variation_noise_scale"] ?? 0.05;
        ___biome_blend_range = _surface[$ "biome_blend_range"] ?? 24;
        ___biome_blend_noise_scale = _surface[$ "biome_blend_noise_scale"] ?? 0.08;
        
        return self;
    }
    
    static set_biome_transition_smoothing = function(_smoothing)
    {
        ___biome_transition_smoothing = _smoothing;
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
        ___cave_start_noise_scale = _start[$ "noise_scale"] ?? _start[$ "scale"] ?? 0.015625;
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
        
        ___cave_noise_scale = _cave[$ "noise_scale"] ?? _cave[$ "scale"] ?? 0.015625;
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
    
    static get_sky_detail_noise_amplitude = function() { return ___sky_detail_noise_amplitude; }
    static get_sky_detail_noise_octaves = function() { return ___sky_detail_noise_octaves; }
    
    static set_biome_transition_smoothing = function(_smoothing)
    {
        ___biome_transition_smoothing = _smoothing;
        return self;
    }
    
    static get_biome_transition_smoothing = function()
    {
        return ___biome_transition_smoothing ?? 0.5;
    }
    
    static set_regions = function(_regions)
    {
        ___regions_ids = _regions;
        ___regions_objects = undefined;
        ___region_generator = undefined;
        
        return self;
    }
    
    static get_regions_ids = function()
    {
        return ___regions_ids;
    }
    
    static __resolve_regions = function()
    {
        if (___regions_ids == undefined || array_length(___regions_ids) == 0) 
        {
            // Create a fallback region if none specified
            var _fallback = new RegionData("fallback", {
                biomes: [{ id: "phantasia:surface/emeraldine/greenia", weight: 1 }],
                cave_biome_default: "phantasia:cave/chasm"
            });
            ___regions_objects = [_fallback];
        }
        else
        {
            var _len = array_length(___regions_ids);
            ___regions_objects = [];
            
            for(var i = 0; i < _len; ++i)
            {
                var _id = worldgen_resolve_id(___regions_ids[i]);
                var _obj = global.region_data[$ _id];
                if (_obj != undefined)
                {
                    array_push(___regions_objects, _obj);
                }
                else
                {
                    PRINT("WorldData: Region not found: " + string(_id));
                }
            }
            
            // If all failed, ensure at least one object exists
            if (array_length(___regions_objects) == 0)
            {
                 var _fallback = new RegionData("fallback", {
                    biomes: [{ id: "phantasia:surface/emeraldine/greenia", weight: 1 }],
                    cave_biome_default: "phantasia:cave/chasm"
                });
                array_push(___regions_objects, _fallback);
                PRINT("WorldData: FAILED to resolve any regions, using emeraldine fallback.");
            }
            else
            {
                PRINT($"WorldData: Resolved {array_length(___regions_objects)} regions: {___regions_ids}");
            }
        }
        
        // Load map buffer if specified
        if (___surface_biome_map != undefined)
        {
            var _asset = global.sprite_asset[$ ___surface_biome_map];
            if (_asset != undefined)
            {
                var _sprite = _asset.get_sprite();
                ___map_width = sprite_get_width(_sprite);
                ___map_height = sprite_get_height(_sprite);
                
                var _surf = surface_create(___map_width, ___map_height);
                
                if (!surface_exists(_surf))
                {
                    PRINT($"WorldData: FAILED to create surface for map: {___surface_biome_map}");
                    
                    exit;
                }
                
                surface_set_target(_surf);
                draw_clear_alpha(c_black, 0);
                draw_sprite(_sprite, 0, sprite_get_xoffset(_sprite), sprite_get_yoffset(_sprite));
                surface_reset_target();
                
                ___map_buffer = buffer_create(___map_width * ___map_height * 4, buffer_fixed, 1);
                buffer_get_surface(___map_buffer, _surf, 0);
                surface_free(_surf);
                
                PRINT($"WorldData: Resolved Region Map '{___surface_biome_map}' ({___map_width}x{___map_height})");
            }
            else
            {
                PRINT($"WorldData: Map asset not found: {___surface_biome_map}");
            }
        }

        ___region_generator = region_gen_create({
            regions: ___regions_objects,
            map_buffer: ___map_buffer,
            map_width: ___map_width,
            map_height: ___map_height,
            map_cell_size: 2048,
            warp_scale: 0.0015,
            warp_power: 384,
        });
    }
    
    static get_region_at = function(_x, _y, _seed)
    {
        if (___region_generator == undefined)
        {
            __resolve_regions();
        }
        
        if (___region_generator == undefined) return undefined;
        
        return region_gen_get_region(___region_generator, _x, _y, _seed);
    }
    
    static get_region_boundary_distance = function(_x, _y, _seed)
    {
        if (___region_generator == undefined)
        {
            __resolve_regions();
        }
        
        if (___region_generator == undefined) return 0;
        
        return region_gen_get_boundary_distance(___region_generator, _x, _y, _seed);
    }
    
    static get_region_blend_data = function(_x, _y, _seed)
    {
        if (___region_generator == undefined)
        {
            __resolve_regions();
        }
        
        if (___region_generator == undefined) return undefined;
        
        return region_gen_get_blend_data(___region_generator, _x, _y, _seed);
    }
    
    static get_sky_detail_noise_amplitude = function()
    {
        return ___sky_detail_noise_amplitude;
    }

    static get_sky_detail_noise_octaves = function()
    {
        return ___sky_detail_noise_octaves;
    }
    
    static set_background = function(_bg)
    {
        ___background_script = _bg[$ "script"];
        ___background_sprites = _bg[$ "sprites"] ?? [];
        ___background_parallax_factor = _bg[$ "parallax_factor"] ?? 0.005;
        ___background_parallax_scale = _bg[$ "parallax_scale"] ?? 1;
        ___background_cloud_count = _bg[$ "cloud_count"] ?? 8;
        ___background_cloud_y_min = _bg[$ "cloud_y_min"] ?? 16;
        ___background_cloud_y_max = _bg[$ "cloud_y_max"] ?? 80;
        ___background_cloud_scale_min = _bg[$ "cloud_scale_min"] ?? 1.2;
        ___background_cloud_scale_max = _bg[$ "cloud_scale_max"] ?? 2.0;
        ___background_cloud_alpha_min = _bg[$ "cloud_alpha_min"] ?? 0.3;
        ___background_cloud_alpha_max = _bg[$ "cloud_alpha_max"] ?? 0.7;
        ___background_cloud_speed_min = _bg[$ "cloud_speed_min"] ?? 1;
        ___background_cloud_speed_max = _bg[$ "cloud_speed_max"] ?? 4;
        ___background_cloud_wind_factor = _bg[$ "cloud_wind_factor"] ?? 0.5;
        
        return self;
    }
    
    static get_background_script = function()
    {
        return ___background_script;
    }
    
    static get_background_sprites = function()
    {
        return ___background_sprites;
    }
    
    static get_background_parallax_factor = function()
    {
        return ___background_parallax_factor;
    }
    
    static get_background_parallax_scale = function()
    {
        return ___background_parallax_scale;
    }
    
    static get_background_cloud_count = function() { return ___background_cloud_count; }
    static get_background_cloud_y_min = function() { return ___background_cloud_y_min; }
    static get_background_cloud_y_max = function() { return ___background_cloud_y_max; }
    static get_background_cloud_scale_min = function() { return ___background_cloud_scale_min; }
    static get_background_cloud_scale_max = function() { return ___background_cloud_scale_max; }
    static get_background_cloud_alpha_min = function() { return ___background_cloud_alpha_min; }
    static get_background_cloud_alpha_max = function() { return ___background_cloud_alpha_max; }
    static get_background_cloud_speed_min = function() { return ___background_cloud_speed_min; }
    static get_background_cloud_speed_max = function() { return ___background_cloud_speed_max; }
    static get_background_cloud_wind_factor = function() { return ___background_cloud_wind_factor; }
    
    static set_colorgrade = function(_colorgrade)
    {
        ___colorgrade_saturation    = _colorgrade[$ "saturation"] ?? 1;
        ___colorgrade_tint_strength = _colorgrade[$ "tint_strength"] ?? 0;
        
        var _tint = _colorgrade[$ "tint"];
        
        if (is_string(_tint))
        {
            var _col = hex_parse(_tint);
            
            ___colorgrade_tint_r = colour_get_red(_col)   / 255;
            ___colorgrade_tint_g = colour_get_green(_col) / 255;
            ___colorgrade_tint_b = colour_get_blue(_col)  / 255;
        }
        
        return self;
    }
    
    static get_colorgrade_saturation    = function() { return ___colorgrade_saturation; }
    static get_colorgrade_tint_r        = function() { return ___colorgrade_tint_r; }
    static get_colorgrade_tint_g        = function() { return ___colorgrade_tint_g; }
    static get_colorgrade_tint_b        = function() { return ___colorgrade_tint_b; }
    static get_colorgrade_tint_strength = function() { return ___colorgrade_tint_strength; }
}