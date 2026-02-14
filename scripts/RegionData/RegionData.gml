function RegionData(_id, _config = {}) constructor
{
    ___id = _id;
    
    ___surface_biome_id = _config[$ "surface_biome"] ?? "phantasia:surface/greenia";
    ___biomes = _config[$ "biomes"] ?? [___surface_biome_id];
    ___biome_count = array_length(___biomes);
    ___biome_noise_scale = _config[$ "biome_noise_scale"] ?? 0.008;
    
    ___cave_biomes = _config[$ "cave_biomes"] ?? [];
    ___cave_biome_count = array_length(___cave_biomes);
    ___cave_biome_default = _config[$ "cave_biome_default"] ?? "phantasia:cave/default";
    
    var _terrain_config = _config[$ "terrain"] ?? {};
    ___terrain = {
        height_offset: _terrain_config[$ "height_offset"] ?? 0,
        base_height: _terrain_config[$ "base_height"] ?? 400,
        amplitude_min: _terrain_config[$ "amplitude_min"] ?? 30,
        amplitude_max: _terrain_config[$ "amplitude_max"] ?? 60,
        noise_scale: _terrain_config[$ "noise_scale"] ?? 0.015625,
        gradient_strength: _terrain_config[$ "gradient_strength"] ?? 0.015
    };
    
    ___fog_color = _config[$ "fog_color"] ?? 0x000000;
    ___fog_density = _config[$ "fog_density"] ?? 0;
    
    // Parse visual properties (sky/light colors as spline gradients)
    var _visuals = _config[$ "visuals"] ?? {};
    
    // Parse sky base colour points (new format: [[time, color], ...])
    var _sky_base_points = _visuals[$ "sky_base"] ?? [];
    ___sky_base_points_length = array_length(_sky_base_points);
    ___sky_base_points = array_create(___sky_base_points_length);
    
    for (var i = 0; i < ___sky_base_points_length; ++i)
    {
        var _p = _sky_base_points[i];
        ___sky_base_points[@ i] = {
            time: _p[0],
            colour: hex_parse(_p[1])
        };
    }
    
    // Parse sky gradient colour points (new format: [[time, color], ...])
    var _sky_gradient_points = _visuals[$ "sky_gradient"] ?? [];
    ___sky_gradient_points_length = array_length(_sky_gradient_points);
    ___sky_gradient_points = array_create(___sky_gradient_points_length);
    
    for (var i = 0; i < ___sky_gradient_points_length; ++i)
    {
        var _p = _sky_gradient_points[i];
        ___sky_gradient_points[@ i] = {
            time: _p[0],
            colour: hex_parse(_p[1])
        };
    }
    
    // Parse light colour points (new format: [[time, color], ...])
    var _light_points = _visuals[$ "light_colour"] ?? [];
    ___light_points_length = array_length(_light_points);
    ___light_points = array_create(___light_points_length);
    
    for (var i = 0; i < ___light_points_length; ++i)
    {
        var _p = _light_points[i];
        ___light_points[@ i] = {
            time: _p[0],
            colour: hex_parse(_p[1])
        };
    }
    
    // Voronoi config for region placement
    var _voronoi = _config[$ "voronoi"];
    if (_voronoi != undefined)
    {
        ___voronoi_cell_size = _voronoi[$ "cell_size"] ?? 256;
        ___voronoi_jitter = _voronoi[$ "jitter"] ?? 0.4;
    }
    else
    {
        ___voronoi_cell_size = 256;
        ___voronoi_jitter = 0.4;
    }
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_surface_biome_id = function(_x = 0, _y = 0, _seed = 0)
    {
        if (___biome_count <= 1) return ___biomes[0];
        
        var _noise = open_simplex_noise(_x * ___biome_noise_scale, _y * ___biome_noise_scale + _seed * 0.1, 1.0, 2);
        var _index = floor((_noise + 1) * 0.5 * ___biome_count) % ___biome_count;
        
        return ___biomes[_index];
    }
    
    static get_biomes = function()
    {
        return ___biomes;
    }
    
    static get_surface_biome = function(_x = 0, _y = 0, _seed = 0)
    {
        return global.biome_data[$ get_surface_biome_id(_x, _y, _seed)];
    }
    
    static get_category = function()
    {
        return ___category;
    }
    
    static set_category = function(_category)
    {
        ___category = _category;
        return self;
    }
    
    /// @desc Get terrain parameters for this zone
    /// @returns {Struct} Terrain config struct
    static get_terrain = function()
    {
        return ___terrain;
    }
    
    static get_sky_base_points = function()
    {
        return ___sky_base_points;
    }
    
    static get_sky_base_points_length = function()
    {
        return ___sky_base_points_length;
    }
    
    static get_sky_gradient_points = function()
    {
        return ___sky_gradient_points;
    }
    
    static get_sky_gradient_points_length = function()
    {
        return ___sky_gradient_points_length;
    }
    
    /// @desc Get sky base colour at a specific time (0..1)
    static get_sky_colour_base = function(_time)
    {
        var _count = ___sky_base_points_length;
        if (_count == 0) return 0xffffff;
        if (_count == 1) return ___sky_base_points[0].colour;
        
        var _idx1 = _count - 1;
        var _idx2 = 0;
        
        for (var i = 0; i < _count - 1; i++) {
            if (_time >= ___sky_base_points[i].time && _time < ___sky_base_points[i+1].time) {
                _idx1 = i;
                _idx2 = i + 1;
                break;
            }
        }
        
        var _p1 = ___sky_base_points[_idx1];
        var _p2 = ___sky_base_points[_idx2];
        
        var _t = 0;
        if (_idx1 == _count - 1 && _idx2 == 0) {
            var _range = (1.0 - _p1.time) + _p2.time;
            if (_range == 0) _t = 0;
            else _t = ((_time >= _p1.time) ? (_time - _p1.time) : ((1.0 - _p1.time) + _time)) / _range;
        } else {
            _t = (_time - _p1.time) / (_p2.time - _p1.time);
        }
        
        return merge_color(_p1.colour, _p2.colour, _t);
    }
    
    /// @desc Get sky gradient colour at a specific time (0..1)
    static get_sky_colour_gradient = function(_time)
    {
        var _count = ___sky_gradient_points_length;
        if (_count == 0) return 0xffffff;
        if (_count == 1) return ___sky_gradient_points[0].colour;
        
        var _idx1 = _count - 1;
        var _idx2 = 0;
        
        for (var i = 0; i < _count - 1; i++) {
            if (_time >= ___sky_gradient_points[i].time && _time < ___sky_gradient_points[i+1].time) {
                _idx1 = i;
                _idx2 = i + 1;
                break;
            }
        }
        
        var _p1 = ___sky_gradient_points[_idx1];
        var _p2 = ___sky_gradient_points[_idx2];
        
        var _t = 0;
        if (_idx1 == _count - 1 && _idx2 == 0) {
            var _range = (1.0 - _p1.time) + _p2.time;
            if (_range == 0) _t = 0;
            else _t = ((_time >= _p1.time) ? (_time - _p1.time) : ((1.0 - _p1.time) + _time)) / _range;
        } else {
            _t = (_time - _p1.time) / (_p2.time - _p1.time);
        }
        
        return merge_color(_p1.colour, _p2.colour, _t);
    }
    
    /// @desc Get light colour at a specific time (0..1)
    static get_light_colour = function(_time)
    {
        var _count = ___light_points_length;
        if (_count == 0) return 0xffffff;
        if (_count == 1) return ___light_points[0].colour;
        
        var _idx1 = _count - 1;
        var _idx2 = 0;
        
        for (var i = 0; i < _count - 1; i++) {
            if (_time >= ___light_points[i].time && _time < ___light_points[i+1].time) {
                _idx1 = i;
                _idx2 = i + 1;
                break;
            }
        }
        
        var _p1 = ___light_points[_idx1];
        var _p2 = ___light_points[_idx2];
        
        var _t = 0;
        if (_idx1 == _count - 1 && _idx2 == 0) {
            var _range = (1.0 - _p1.time) + _p2.time;
            if (_range == 0) _t = 0;
            else _t = ((_time >= _p1.time) ? (_time - _p1.time) : ((1.0 - _p1.time) + _time)) / _range;
        } else {
            _t = (_time - _p1.time) / (_p2.time - _p1.time);
        }
        
        return merge_color(_p1.colour, _p2.colour, _t);
    }
    
    static get_voronoi_cell_size = function()
    {
        return ___voronoi_cell_size;
    }
    
    static get_voronoi_jitter = function()
    {
        return ___voronoi_jitter;
    }
    
    /// @desc Get resolved surface BiomeData for a position within this region
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _seed World seed
    /// @returns {Struct.BiomeData}
    static get_surface_biome = function(_x, _y, _seed)
    {
        if (___biome_count == 1) return global.biome_data[$ ___biomes[0]];
        
        var _noise = open_simplex_noise(_x * ___biome_noise_scale, _seed * 0.5, 1.0, 2);
        var _noise_norm = (_noise + 1) * 0.5;
        
        var _index = floor(_noise_norm * ___biome_count);
        _index = clamp(_index, 0, ___biome_count - 1);
        
        var _id = ___biomes[_index];
        return global.biome_data[$ _id] ?? global.biome_data[$ ___biomes[0]];
    }
    
    /// @desc Get cave sub-biome ID based on position and depth
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position (depth layer, 0-2)
    /// @param {Real} _depth Depth from surface (positive = underground)
    /// @param {Real} _seed World seed
    /// @returns {String} Biome ID for this cave position
    static get_cave_biome_id = function(_x, _y, _z, _depth, _seed)
    {
        // Evaluate rules in priority order
        for (var i = 0; i < ___cave_biome_count; ++i)
        {
            var _rule = ___cave_biomes[i];
            
            if (___evaluate_cave_rule(_rule, _x, _y, _z, _depth, _seed))
            {
                return _rule.biome;
            }
        }
        
        return ___cave_biome_default;
    }
    
    /// @desc Get resolved cave BiomeData
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position
    /// @param {Real} _depth Depth from surface
    /// @param {Real} _seed World seed
    /// @returns {Struct.BiomeData}
    static get_cave_biome = function(_x, _y, _z, _depth, _seed)
    {
        var _biome_id = get_cave_biome_id(_x, _y, _z, _depth, _seed);
        return global.biome_data[$ _biome_id] ?? global.biome_data[$ ___cave_biome_default];
    }
    
    /// @desc Evaluate a cave sub-biome rule
    /// @private
    static ___evaluate_cave_rule = function(_rule, _x, _y, _z, _depth, _seed)
    {
        // 1. Check depth range
        if (variable_struct_exists(_rule, "min_depth"))
        {
            if (_depth < _rule.min_depth) return false;
        }
        
        if (variable_struct_exists(_rule, "max_depth"))
        {
            if (_depth > _rule.max_depth) return false;
        }
        
        // 2. Check noise threshold (for scattered sub-biomes)
        if (variable_struct_exists(_rule, "noise_threshold"))
        {
            var _noise_scale = _rule[$ "noise_scale"] ?? 0.02;
            var _noise = open_simplex_noise(
                _x * _noise_scale,
                _y * _noise_scale,
                1.0,
                2
            );
            
            // Normalize from -1..1 to 0..1
            _noise = (_noise + 1) * 0.5;
            
            if (_noise < _rule.noise_threshold) return false;
        }
        
        // 3. Check weight/chance (for random variation)
        if (variable_struct_exists(_rule, "weight") && _rule.weight < 1.0)
        {
            var _roll_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _seed;
            var _roll = frac(sin(_roll_seed * 0.0001) * 43758.5453);
            
            if (_roll > _rule.weight) return false;
        }
        
        // 4. Check Z-layer (0 = back, 1 = mid, 2 = front)
        if (variable_struct_exists(_rule, "z_layer"))
        {
            if (_z != _rule.z_layer) return false;
        }
        
        return true;
    }
    
    // --- Setters (fluent API) ---
    
    static set_surface_biome = function(_biome_id)
    {
        ___surface_biome_id = _biome_id;
        return self;
    }
    
    static set_cave_biome_default = function(_biome_id)
    {
        ___cave_biome_default = _biome_id;
        return self;
    }
    
    /// @desc Add a cave sub-biome rule
    /// @param {Struct} _rule { biome: String, min_depth?, max_depth?, noise_threshold?, weight?, z_layer? }
    static add_cave_biome = function(_rule)
    {
        array_push(___cave_biomes, _rule);
        ___cave_biome_count = array_length(___cave_biomes);
        return self;
    }
    
    static set_terrain = function(_terrain_config)
    {
        if (_terrain_config != undefined)
        {
            ___terrain.height_offset = _terrain_config[$ "height_offset"] ?? ___terrain.height_offset;
            ___terrain.base_height = _terrain_config[$ "base_height"] ?? ___terrain.base_height;
            ___terrain.amplitude_min = _terrain_config[$ "amplitude_min"] ?? ___terrain.amplitude_min;
            ___terrain.amplitude_max = _terrain_config[$ "amplitude_max"] ?? ___terrain.amplitude_max;
            ___terrain.noise_scale = _terrain_config[$ "noise_scale"] ?? ___terrain.noise_scale;
            ___terrain.gradient_strength = _terrain_config[$ "gradient_strength"] ?? ___terrain.gradient_strength;
        }
        return self;
    }
}

/// @desc Create example regions for testing
/// @returns {Array<Struct.RegionData>}
function region_create_defaults()
{
    return [
        // Region 0: Forest (default)
        new RegionData("forest", {
            category: "temperate",
            surface_biome: "phantasia:surface/greenia",
            cave_biome_default: "phantasia:cave/chasm",
            cave_biomes: [
                { biome: "phantasia:cave/depths", min_depth: 150, noise_threshold: 0.7, noise_scale: 0.015 }
            ]
        }),
        
        // Region 1: Desert
        new RegionData("desert", {
            category: "arid",
            surface_biome: "phantasia:surface/dune",
            cave_biome_default: "phantasia:cave/chasm",
            terrain: { height_offset: 10, base_height: 410, amplitude_min: 15, amplitude_max: 35 },
            cave_biomes: [
                { biome: "phantasia:cave/depths", min_depth: 250, noise_threshold: 0.6 }
            ]
        }),
        
        // Region 2: Taiga (formerly tundra)
        new RegionData("taiga", {
            category: "cold",
            surface_biome: "phantasia:surface/pinesteep",
            cave_biome_default: "phantasia:cave/chasm",
            terrain: { height_offset: -20, base_height: 380, amplitude_min: 20, amplitude_max: 50 },
            cave_biomes: [
                { biome: "phantasia:cave/depths", min_depth: 100, noise_threshold: 0.5 }
            ]
        })
    ];
}
