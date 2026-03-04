function RegionData(_id, _config = {}) constructor
{
    ___id = _id;
    
    // Parse biomes array — each entry has { id, weight, terrain_preference }
    var _biomes_raw = _config[$ "biomes"] ?? [];
    ___biomes = [];
    ___biome_count = array_length(_biomes_raw);
    ___biome_noise_scale = _config[$ "biome_noise_scale"] ?? 0.008;
    
    // Pre-sorted biome lists for terrain-shape priority
    ___biome_flat = [];
    ___biome_hilly = [];
    ___biome_any = [];
    ___biome_total_weight_flat = 0;
    ___biome_total_weight_hilly = 0;
    
    for (var i = 0; i < ___biome_count; ++i)
    {
        var _b = _biomes_raw[i];
        var _entry = {
            id: _b[$ "id"] ?? _b,
            weight: _b[$ "weight"] ?? 1,
            terrain_preference: _b[$ "terrain_preference"] ?? "any"
        }
        array_push(___biomes, _entry);
        
        var _pref = _entry.terrain_preference;
        if (_pref == "flat" || _pref == "any")
        {
            array_push(___biome_flat, _entry);
            ___biome_total_weight_flat += _entry.weight;
        }
        if (_pref == "hilly" || _pref == "any")
        {
            array_push(___biome_hilly, _entry);
            ___biome_total_weight_hilly += _entry.weight;
        }
        if (_pref == "any")
        {
            array_push(___biome_any, _entry);
        }
    }
    
    ___biome_flat_count = array_length(___biome_flat);
    ___biome_hilly_count = array_length(___biome_hilly);
    
    ___cave_biomes = _config[$ "cave_biomes"] ?? [];
    ___cave_biome_count = array_length(___cave_biomes);
    ___cave_biome_default = _config[$ "cave_biome_default"] ?? "phantasia:cave/default";
    
    var _terrain_config = _config[$ "terrain"] ?? {}
    ___terrain = {
        height_offset: _terrain_config[$ "height_offset"] ?? 0,
        base_height: _terrain_config[$ "base_height"] ?? 0,
        amplitude_min: _terrain_config[$ "amplitude_min"] ?? 30,
        amplitude_max: _terrain_config[$ "amplitude_max"] ?? 60,
        noise_scale: _terrain_config[$ "noise_scale"] ?? 0.015625,
        octaves: _terrain_config[$ "octaves"] ?? 4,
    }
    
    ___category = _config[$ "category"] ?? ___id;
    ___map_color = is_string(_config[$ "map_color"]) ? hex_parse(_config[$ "map_color"]) : (_config[$ "map_color"] ?? c_white);
    ___fog_color = undefined;
    ___particles = undefined;
    
    // Heat & humidity climate targets (for region selection)
    // Range: [0, 63) matching open_simplex_noise output
    // Default targets based on category if not explicitly set
    var _default_heat = 31;
    var _default_humid = 31;
    switch (___category)
    {
        case "frozen":    _default_heat = 6;  _default_humid = 13; break;
        case "cold":      _default_heat = 19; _default_humid = 28; break;
        case "temperate": _default_heat = 35; _default_humid = 41; break;
        case "humid":     _default_heat = 41; _default_humid = 57; break;
        case "arid":      _default_heat = 57; _default_humid = 9;  break;
    }
    ___heat_target = _config[$ "heat"] ?? _default_heat;
    ___humidity_target = _config[$ "humidity"] ?? _default_humid;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_map_color = function()
    {
        return ___map_color;
    }
    
    /// @desc Get surface biome ID based on position, seed, and terrain slope
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position (typically surface height)
    /// @param {Real} _seed World seed
    /// @param {Real} _slope Terrain slope (0 = flat, 1 = very hilly), optional
    /// @returns {String} Biome ID
    static get_surface_biome_id = function(_x = 0, _y = 0, _seed = 0, _slope = 0)
    {
        // Fast path: single biome
        if (___biome_count <= 1)
        {
            return (___biome_count == 0) ? "" : ___biomes[0].id;
        }
        
        // Determine which list to pick from based on terrain slope
        // slope < 0.15 = "flat", slope >= 0.15 = "hilly"
        var _is_hilly = (_slope >= 0.15);
        var _pool = _is_hilly ? ___biome_hilly : ___biome_flat;
        var _pool_count = _is_hilly ? ___biome_hilly_count : ___biome_flat_count;
        var _total_weight = _is_hilly ? ___biome_total_weight_hilly : ___biome_total_weight_flat;
        
        // Fallback to all biomes if the preferred pool is empty
        if (_pool_count == 0)
        {
            _pool = ___biomes;
            _pool_count = ___biome_count;
            _total_weight = 0;
            for (var i = 0; i < _pool_count; ++i)
            {
                _total_weight += _pool[i].weight;
            }
        }
        
        // Use noise to pick a biome coherently across horizontal space
        // NOTE: Only use _x for coherence — using _y (surface height) caused rapid
        // biome alternation because surface height varies per column at high frequency.
        var _noise = open_simplex_noise(
            _x * ___biome_noise_scale,
            1024,
            1.0, 2
        );
        
        // Map noise from [0, 1) to [0, total_weight)
        var _pick = _noise * _total_weight;
        
        // Weighted selection
        var _accum = 0;
        for (var i = 0; i < _pool_count; ++i)
        {
            _accum += _pool[i].weight;
            if (_pick < _accum)
            {
                return _pool[i].id;
            }
        }
        
        // Fallback
        return _pool[_pool_count - 1].id;
    }
    
    static get_biomes = function()
    {
        return ___biomes;
    }
    
    static get_surface_biome = function(_x = 0, _y = 0, _seed = 0, _slope = 0)
    {
        return global.biome_data[$ get_surface_biome_id(_x, _y, _seed, _slope)];
    }
    
    static get_category = function()
    {
        return ___category;
    }
    
    static set_map_color = function(_color)
    {
        ___map_color = hex_parse(_color);
        return self;
    }
    
    static get_heat_target = function()
    {
        return ___heat_target;
    }
    
    static get_humidity_target = function()
    {
        return ___humidity_target;
    }
    
    static get_sky_colour = function(_time)
    {
        if (___biome_count == 0) return c_black;
        return worldgen_get_sky_colour(___biomes[0].id, _time);
    }
    
    static get_light_colour = function(_time)
    {
        if (___biome_count == 0) return c_white;
        return worldgen_get_light_colour(___biomes[0].id, _time);
    }
    
    static get_background = function()
    {
        if (___biome_count == 0) return undefined;
        var _biome = global.biome_data[$ ___biomes[0].id];
        if (_biome == undefined) return undefined;
        return _biome.get_background();
    }
    
    static get_music = function()
    {
        if (___biome_count == 0) return undefined;
        var _biome = global.biome_data[$ ___biomes[0].id];
        if (_biome == undefined) return undefined;
        return _biome.get_music();
    }
    
    static set_category = function(_category)
    {
        ___category = _category;
        return self;
    }
    
    /// @desc Get terrain parameters for this region
    /// @returns {Struct} Terrain config struct
    static get_terrain = function()
    {
        return ___terrain;
    }
    
    static get_surface_height = function(_x, _seed)
    {
        var _t = ___terrain;
        
        var _noise = open_simplex_noise(_x * _t.noise_scale, -256, (_t.amplitude_min + _t.amplitude_max) * 0.5, _t.octaves);
        
        return _t.height_offset + _t.base_height + _noise;
    }
    
    static set_fog_color = function(_color)
    {
        ___fog_color = _color; // hex string or struct?
        return self;
    }
    
    static get_fog_color = function()
    {
        return self[$ "___fog_color"];
    }
    
    static set_particles = function(_particles)
    {
        ___particles = _particles;
        return self;
    }
    
    static get_particles = function()
    {
        return self[$ "___particles"];
    }
    
    // --- Cave Sub-Biome System ---
    
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
        if (struct_exists(_rule, "min_depth"))
        {
            if (_depth < _rule.min_depth) return false;
        }
        
        if (struct_exists(_rule, "max_depth"))
        {
            if (_depth > _rule.max_depth) return false;
        }
        
        // 2. Check noise threshold (for scattered sub-biomes)
        if (struct_exists(_rule, "noise_threshold"))
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
        if (struct_exists(_rule, "weight") && _rule.weight < 1.0)
        {
            var _roll_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _seed;
            var _roll = frac(sin(_roll_seed * 0.0001) * 43758.5453);
            
            if (_roll > _rule.weight) return false;
        }
        
        // 4. Check Z-layer (0 = back, 1 = mid, 2 = front)
        if (struct_exists(_rule, "z_layer"))
        {
            if (_z != _rule.z_layer) return false;
        }
        
        return true;
    }
    
    // --- Setters (fluent API) ---
    
    static set_cave_biome_default = function(_biome_id)
    {
        ___cave_biome_default = _biome_id;
        return self;
    }
    
    /// @desc Add a cave sub-biome rule
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
            ___terrain.octaves = _terrain_config[$ "octaves"] ?? ___terrain.octaves;
        }
        return self;
    }
}
