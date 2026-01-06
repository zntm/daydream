/// @desc Zone Data struct with Sub-Biome rule system
/// @description Defines a geographic zone and its sub-biome rules for caves/surface.
///              Sub-biomes are selected based on depth, noise, and custom conditions.

/// @param {String} _id Zone identifier
/// @param {Struct} _config Configuration struct
function RegionData(_id, _config = {}) constructor
{
    ___id = _id;
    
    // Surface biome reference (uses existing BiomeData system)
    ___surface_biome_id = _config[$ "surface_biome"] ?? "phantasia:surface/forest";
    
    // Cave sub-biome rules (evaluated in order, first match wins)
    ___cave_biomes = _config[$ "cave_biomes"] ?? [];
    ___cave_biome_count = array_length(___cave_biomes);
    ___cave_biome_default = _config[$ "cave_biome_default"] ?? "phantasia:cave/default";
    
    // Terrain parameters for this zone
    var _terrain_config = _config[$ "terrain"] ?? {};
    ___terrain = {
        height_offset: _terrain_config[$ "height_offset"] ?? 0,
        base_height: _terrain_config[$ "base_height"] ?? 400,
        amplitude_min: _terrain_config[$ "amplitude_min"] ?? 30,
        amplitude_max: _terrain_config[$ "amplitude_max"] ?? 60,
        noise_scale: _terrain_config[$ "noise_scale"] ?? 0.015625,
        gradient_strength: _terrain_config[$ "gradient_strength"] ?? 0.015
    };
    
    // Zone visual/ambient properties
    ___fog_color = _config[$ "fog_color"] ?? 0x000000;
    ___fog_density = _config[$ "fog_density"] ?? 0;
    
    // --- Getters ---
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_surface_biome_id = function()
    {
        return ___surface_biome_id;
    }
    
    /// @desc Get resolved surface BiomeData
    /// @returns {Struct.BiomeData}
    static get_surface_biome = function()
    {
        return global.biome_data[$ ___surface_biome_id];
    }
    
    /// @desc Get terrain parameters for this zone
    /// @returns {Struct} Terrain config struct
    static get_terrain = function()
    {
        return ___terrain;
    }
    
    // --- Sub-Biome System ---
    
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
            surface_biome: "phantasia:surface/forest",
            cave_biome_default: "phantasia:cave/default",
            cave_biomes: [
                { biome: "phantasia:cave/lush", min_depth: 80, noise_threshold: 0.7, noise_scale: 0.015 },
                { biome: "phantasia:cave/crystal", min_depth: 150, noise_threshold: 0.85, noise_scale: 0.01 }
            ]
        }),
        
        // Region 1: Desert
        new RegionData("desert", {
            surface_biome: "phantasia:surface/desert",
            cave_biome_default: "phantasia:cave/sandstone",
            terrain: { height_offset: 10, base_height: 410, amplitude_min: 15, amplitude_max: 35 },
            cave_biomes: [
                { biome: "phantasia:cave/volcanic", min_depth: 200, noise_threshold: 0.6 }
            ]
        }),
        
        // Region 2: Tundra
        new RegionData("tundra", {
            surface_biome: "phantasia:surface/tundra",
            cave_biome_default: "phantasia:cave/ice",
            terrain: { height_offset: -20, base_height: 380, amplitude_min: 20, amplitude_max: 50 },
            cave_biomes: [
                { biome: "phantasia:cave/frozen", min_depth: 50, noise_threshold: 0.5 }
            ]
        })
    ];
}
