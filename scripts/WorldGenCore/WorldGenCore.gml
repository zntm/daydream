/// @desc WorldGenCore - Unified world generation system
/// Replaces TerrainShaper with a cleaner, more maintainable API.
/// All noise/spline parameters are centralized here.

/// @desc Helper to create a spline point struct
/// @param {Real} _pos Position (input value, e.g. depth)
/// @param {Real} _val Value (output value, e.g. squash factor)
/// @param {String} _ease Optional easing type
function sp(_pos, _val, _ease = undefined)
{
    var _pt = { position: _pos, value: _val };
    if (_ease != undefined) _pt.easing = _ease;
    
    return _pt;
}

/// @param {Struct.WorldData} _world_data World data struct
/// @returns {Struct.WorldGenCore}
function WorldGenCore(_world_data) constructor
{
    ___world_data = _world_data;
    
    // --- SURFACE SHAPE PARAMETERS ---
    
    /// Base height of the surface (in tiles)
    ___base_height = _world_data.get_surface_start();
    
    /// 2D noise scales for surface traits
    ___erosion_scale = _world_data.get_worldgen_erosion_scale();
    ___continentalness_scale = _world_data.get_worldgen_continentalness_scale();
    ___continentalness_amplitude = _world_data.get_worldgen_continentalness_amplitude();
    
    /// Squashing spline (depth-based): Flattens caves/overhangs near surface
    ___squash_spline = _world_data.get_worldgen_squash_spline() ?? [
        sp(0, 6.0, "ease_out"),      // Near surface: very flat overhangs
        sp(100, 3.0, "ease_in_out"), // Shallow: moderately flat
        sp(400, 1.0)                  // Deep: normal caves
    ];
    
    // --- CAVE SHAPE PARAMETERS ---
    
    ___cave_noise_scale = _world_data.get_worldgen_cave_noise_scale();
    
    /// Noise range spline: What noise values carve out caves
    ___cave_noise_range_spline = _world_data.get_worldgen_cave_noise_range_spline() ?? [
        sp(0, 0.05, "ease_out"),     // Surface: almost no caves
        sp(50, 0.15, "ease_in_out"), // Shallow: small pockets
        sp(200, 0.35),                // Mid: medium caves
        sp(500, 0.5)                  // Deep: large caves
    ];
    
    /// Density spline: How much of a cave is air vs solid
    ___cave_density_spline = _world_data.get_worldgen_cave_density_spline() ?? [
        sp(0, 0.1, "ease_out"),      // Surface: mostly solid
        sp(100, 0.3, "ease_in_out"), // Shallow: some air
        sp(400, 0.5)                  // Deep: half air
    ];
    
    /// Smoothness spline: Octaves for 3D noise (higher = smoother edges)
    ___cave_smoothness_spline = _world_data.get_worldgen_cave_smoothness_spline() ?? [
        sp(0, 2),                     // Surface: jagged
        sp(300, 4)                    // Deep: smooth tunnels
    ];
    
    // --- PUBLIC METHODS ---
    
    /// @desc Evaluate surface height at a given X position
    /// @param {Real} _x World X position
    /// @param {Struct} _region Optional region data (for compatibility, currently unused)
    /// @param {Real} _seed World seed
    /// @returns {Real} Surface height (in tiles)
    static get_surface_height = function(_x, _region_or_seed, _seed = undefined)
    {
        // Handle both signatures: (x, seed) and (x, region, seed)
        var _actual_seed = _seed ?? _region_or_seed;
        
        // Binary search for where density crosses 0 (air -> solid boundary)
        var _min_y = ___base_height - 400;
        var _max_y = ___base_height + 400;
        
        for (var i = 0; i < 12; ++i)
        {
            var _mid_y = (_min_y + _max_y) * 0.5;
            var _density = get_density(_x, _mid_y, 0, _actual_seed);
            
            if (_density > 0) _max_y = _mid_y;
            else _min_y = _mid_y;
        }
        
        return floor((_min_y + _max_y) * 0.5);
    }
    
    /// @desc Check if a position is solid (for base tiles)
    /// @param {Real} _x, _y World position
    /// @param {Real} _seed World seed
    /// @returns {Bool} True if solid
    static is_solid = function(_x, _y, _seed)
    {
        return get_density(_x, _y, 0, _seed) > 0;
    }
    
    /// @desc Check if a position is solid for walls (extended Z offset)
    /// @param {Real} _x, _y World position
    /// @param {Real} _seed World seed
    /// @returns {Bool} True if wall should exist
    static is_wall = function(_x, _y, _seed)
    {
        var _z_offset = ___world_data.get_terrain_z_offset_wall();
        var _z_range = ___world_data.get_terrain_z_range_wall();
        
        if (_z_range <= 0) return get_density(_x, _y, _z_offset, _seed) > 0;
        
        // Sample Z range for thicker walls
        var _d1 = get_density(_x, _y, _z_offset - _z_range, _seed);
        var _d2 = get_density(_x, _y, _z_offset, _seed);
        var _d3 = get_density(_x, _y, _z_offset + _z_range, _seed);
        
        return max(_d1, _d2, _d3) > 0;
    }
    
    /// @desc Core density evaluation with biome modifier blending
    /// @param {Real} _x, _y World position
    /// @param {Real} _z Z-slice (0 = solid, offset = wall)
    /// @param {Real} _seed World seed
    /// @returns {Real} Density (positive = solid, negative = air)
    static get_density = function(_x, _y, _z, _seed)
    {
        var _depth = _y - ___base_height;
        
        // === Biome modifier blending ===
        var _mods = get_biome_modifiers(_x, _y, _seed);
        var _erosion_mod = _mods.erosion;
        var _squash_mod = _mods.squash;
        var _cave_density_mod = _mods.cave_density;
        var _continentalness_mod = _mods.continentalness;
        
        // === 1. Height gradient ===
        var _gradient_strength = 0.006;
        var _height_gradient = _depth * _gradient_strength;
        
        // === 2. Continentalness (large-scale land mass variation) ===
        var _continentalness = open_simplex_noise(_x * ___continentalness_scale, _seed * 7.3, 1.0, 2);
        _continentalness += _continentalness_mod; // Apply biome modifier
        _height_gradient -= _continentalness * ___continentalness_amplitude * _gradient_strength;
        
        // === 3. Squashing (Y-dependent via spline, modified by biome) ===
        var _squash = spline_evaluate(___squash_spline, _depth) * _squash_mod;
        var _squashed_y = _y * _squash;
        
        // === 4. 3D cave noise ===
        var _smoothness = spline_evaluate(___cave_smoothness_spline, _depth);
        var _noise_3d = open_simplex_noise_3d(
            _x * ___cave_noise_scale,
            _squashed_y * ___cave_noise_scale,
            _z + (_seed * 0.0001),
            1.0,
            _smoothness
        );
        
        // === 5. Cave density modifier (Y-dependent via spline, modified by biome) ===
        var _cave_density = spline_evaluate(___cave_density_spline, _depth) * _cave_density_mod;
        var _noise_range = spline_evaluate(___cave_noise_range_spline, _depth);
        
        // === 6. Erosion (local flatness variation, modified by biome) ===
        var _erosion = open_simplex_noise(_x * ___erosion_scale, _y * ___erosion_scale + 500, 1.0, 2);
        _erosion *= _erosion_mod;
        
        // === 7. Final density ===
        var _cave_carve = (_noise_3d > -_noise_range && _noise_3d < _noise_range) ? -_cave_density : 0;
        var _density = _height_gradient + (_noise_3d * (1.8 + _erosion * 0.8)) + _cave_carve;
        
        return _density - 0.05;
    }
    
    /// @desc Get blended biome modifiers for smooth biome edge transitions
    /// @param {Real} _x, _y World position
    /// @param {Real} _seed World seed
    /// @returns {Struct} { erosion, squash, cave_density, continentalness }
    static get_biome_modifiers = function(_x, _y, _seed)
    {
        // Get current biome
        var _region = global.region_generator.get_region(_x, _y, 0, _seed);
        var _biome_id = _region.get_surface_biome_id();
        var _biome = global.biome_data[$ _biome_id];
        
        if (_biome == undefined)
        {
            return { erosion: 1.0, squash: 1.0, cave_density: 1.0, continentalness: 0.0 };
        }
        
        var _smoothing = _biome.get_terrain_smoothing();
        var _influence = _biome.get_terrain_influence();
        
        // Base modifiers from current biome
        var _erosion = lerp(1.0, _biome.get_erosion_modifier(), _influence);
        var _squash = lerp(1.0, _biome.get_squash_modifier(), _influence);
        var _cave_density = lerp(1.0, _biome.get_cave_density_modifier(), _influence);
        var _continentalness = _biome.get_continentalness_modifier() * _influence;
        
        // Sample nearby biomes for edge blending
        if (_smoothing > 0)
        {
            var _boundary_dist = global.region_generator.get_boundary_distance(_x, _y, 0, _seed);
            if (_boundary_dist < _smoothing)
            {
                // Blend factor: 0 at boundary, 1 at smoothing distance
                var _blend = _boundary_dist / _smoothing;
                var _blend_smooth = _blend * _blend * (3 - 2 * _blend); // Smoothstep
                
                // At boundary, lerp toward neutral values (1.0 for multipliers, 0 for additives)
                _erosion = lerp(1.0, _erosion, _blend_smooth);
                _squash = lerp(1.0, _squash, _blend_smooth);
                _cave_density = lerp(1.0, _cave_density, _blend_smooth);
                _continentalness = lerp(0.0, _continentalness, _blend_smooth);
            }
        }
        
        return { erosion: _erosion, squash: _squash, cave_density: _cave_density, continentalness: _continentalness };
    }
    
    // --- 2D NOISE SAMPLING (for biome traits) ---
    
    /// @desc Get erosion value at a position (how flat the area is)
    /// @returns {Real} 0.0 (very eroded/flat) to 1.0 (mountainous)
    static get_erosion = function(_x, _seed)
    {
        var _noise = open_simplex_noise(_x * ___erosion_scale, _seed * 3.14, 1.0, 2);
        return (_noise + 1) * 0.5; // Normalize to 0-1
    }
    
    /// @desc Get continentalness at a position (how much "land" an area is)
    /// @returns {Real} -1.0 (ocean) to 1.0 (continental interior)
    static get_continentalness = function(_x, _seed)
    {
        return open_simplex_noise(_x * ___continentalness_scale, _seed * 7.3, 1.0, 2);
    }
    
    /// @desc Get peaks/valleys value at a position
    /// @returns {Real} -1.0 (valley) to 1.0 (peak)
    static get_peaks = function(_x, _seed)
    {
        return open_simplex_noise(_x * ___peaks_scale, _seed * 13.7, 1.0, 3);
    }
    
    // --- TERRAINSHAPER COMPATIBILITY API ---
    // These methods match the old TerrainShaper signature for drop-in replacement.
    
    /// @desc TerrainShaper-compatible: Get density for solid tiles (Z=0)
    static get_density_solid = function(_x, _y, _seed)
    {
        return get_density(_x, _y, 0, _seed);
    }
    
    /// @desc TerrainShaper-compatible: Get density for wall tiles
    static get_density_wall = function(_x, _y, _seed)
    {
        var _z_offset = ___world_data.get_terrain_z_offset_wall();
        var _z_range = ___world_data.get_terrain_z_range_wall();
        
        if (_z_range <= 0) return get_density(_x, _y, _z_offset, _seed);
        
        var _d1 = get_density(_x, _y, _z_offset - _z_range, _seed);
        var _d2 = get_density(_x, _y, _z_offset, _seed);
        var _d3 = get_density(_x, _y, _z_offset + _z_range, _seed);
        
        return max(_d1, _d2, _d3);
    }
    
    /// @desc TerrainShaper-compatible: Get density for material variation
    static get_density_material = function(_x, _y, _seed)
    {
        var _z_offset = ___world_data.get_terrain_z_offset_material();
        return get_density(_x, _y, _z_offset, _seed);
    }
}
