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
    ___surface_start = 400; // Default base height
    
    // Legacy WorldGen Defaults (Still used by worldgen_get_tile_base)
    ___bedrock_depth = 3;
    ___bedrock_noise_scale = 0.3;
    ___tile_variation_noise_scale = 0.05;
    
    // Default initializations to prevent "Variable not set" errors
    ___cave_biome_default = [];
    ___cave_biome_default_length = 0;
    ___cave_biome_depth_zones = [];
    ___cave_biome_depth_zones_length = 0;
    ___cave_biome_map = undefined;
    ___cave_biome_heat = undefined;
    ___cave_biome_humidity = undefined;
    
    ___surface_biome = undefined;
    ___surface_biome_map = undefined;
    ___surface_biome_heat = { octaves: 1 }
    ___surface_biome_humidity = { octaves: 1 }
    ___surface_heat_noise_scale = 0.01;
    ___surface_heat_offset = 0;
    ___surface_heat_range = 63;
    ___surface_humidity_noise_scale = 0.01;
    ___surface_humidity_offset = 0;
    ___surface_humidity_range = 63;
    ___surface_heat_spline_x = undefined;
    ___surface_heat_spline_y = undefined;
    ___surface_humidity_spline_x = undefined;
    ___surface_humidity_spline_y = undefined;
    ___surface_biome_transitions = [];
    
    ___worldgen_erosion_scale = 0.008;
    ___worldgen_continentalness_scale = 0.001;
    ___worldgen_continentalness_amplitude = 150;
    ___worldgen_cave_noise_scale = 0.015;
    ___worldgen_squash_spline = undefined;
    ___worldgen_cave_noise_range_spline = undefined;
    ___worldgen_cave_density_spline = undefined;
    ___worldgen_cave_smoothness_spline = undefined;
    ___worldgen_region_height_scale = 1.0;
    
    ___biome_blend_range = 24; // Default blend range

    static get_biome_blend_range = function()
    {
        return ___biome_blend_range;
    }
    
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
        ___vignette_colour = hex_parse(_colour);
        
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
        ___biome_blend_range = _surface_biome[$ "biome_blend_range"] ?? 24;
        
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
    
    static get_terrain_z_offset_wall = function() { return 0.075; }
    static get_terrain_z_range_wall = function() { return 0.05; }
    static get_terrain_z_offset_material = function() { return 0.5; }
    
    static get_worldgen_erosion_scale = function() { return ___worldgen_erosion_scale; }
    static get_worldgen_continentalness_scale = function() { return ___worldgen_continentalness_scale; }
    static get_worldgen_continentalness_amplitude = function() { return ___worldgen_continentalness_amplitude; }
    static get_worldgen_cave_noise_scale = function() { return ___worldgen_cave_noise_scale; }
    
    static get_worldgen_squash_spline = function() { return ___worldgen_squash_spline; }
    static get_worldgen_cave_noise_range_spline = function() { return ___worldgen_cave_noise_range_spline; }
    static get_worldgen_cave_density_spline = function() { return ___worldgen_cave_density_spline; }
    static get_worldgen_cave_smoothness_spline = function() { return ___worldgen_cave_smoothness_spline; }
    static get_worldgen_region_height_scale = function() { return ___worldgen_region_height_scale; }
    
    /// @desc Set worldgen config (new unified system)
    static set_worldgen = function(_config)
    {
        if (_config == undefined)
        {
            return self;
        }
        
        // Surface shape
        // Surface shape
        ___surface_start = _config[$ "surface_start"] ?? ___surface_start;
        ___worldgen_erosion_scale = _config[$ "erosion_scale"] ?? 0.008;
        ___worldgen_continentalness_scale = _config[$ "continentalness_scale"] ?? 0.001;
        ___worldgen_continentalness_scale = _config[$ "continentalness_scale"] ?? 0.001;
        ___worldgen_continentalness_amplitude = _config[$ "continentalness_amplitude"] ?? 150;
        ___worldgen_region_height_scale = _config[$ "region_height_scale"] ?? 1.0;
        
        var _squash = _config[$ "squash_spline"];
        ___worldgen_squash_spline = (_squash != undefined && _squash[$ "points"] != undefined) ? _squash.points : _squash;
        
        // Cave shape
        ___worldgen_cave_noise_scale = _config[$ "cave_noise_scale"] ?? 0.015;
        
        var _noise_range = _config[$ "cave_noise_range_spline"];
        ___worldgen_cave_noise_range_spline = (_noise_range != undefined && _noise_range[$ "points"] != undefined) ? _noise_range.points : _noise_range;
        
        var _density = _config[$ "cave_density_spline"];
        ___worldgen_cave_density_spline = (_density != undefined && _density[$ "points"] != undefined) ? _density.points : _density;
        
        var _smoothness = _config[$ "cave_smoothness_spline"];
        ___worldgen_cave_smoothness_spline = (_smoothness != undefined && _smoothness[$ "points"] != undefined) ? _smoothness.points : _smoothness;
        
        return self;
    }
    
    
    static get_surface_start = function()
    {
        return ___surface_start;
    }
    
    
    static get_bedrock_depth = function() { return ___bedrock_depth; }
    static get_bedrock_noise_scale = function() { return ___bedrock_noise_scale; }
    static get_tile_variation_noise_scale = function() { return ___tile_variation_noise_scale; }
    
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