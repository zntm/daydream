/// @desc TerrainGenerator - Density-based terrain evaluation for complex terrain shapes
/// Converts world coordinates into a density value, where positive = solid, negative = air

/// @param {Struct} _config Configuration struct
/// @returns {Struct.TerrainGenerator}
function TerrainGenerator(_config = {}) constructor
{
    // Default density settings
    ___base_surface_y = _config[$ "base_surface_y"] ?? 400;
    ___world_height = _config[$ "world_height"] ?? 1200;
    
    // Noise configuration
    ___noise_scale = _config[$ "noise_scale"] ?? 0.02;
    ___noise_octaves = _config[$ "noise_octaves"] ?? 4;
    ___noise_persistence = _config[$ "noise_persistence"] ?? 0.5;
    ___noise_lacunarity = _config[$ "noise_lacunarity"] ?? 2.0;
    
    // Vertical gradient settings
    ___gradient_strength = _config[$ "gradient_strength"] ?? 0.015;
    
    /// @desc Get density at a world position
    /// @param {Real} _x World X coordinate
    /// @param {Real} _y World Y coordinate  
    /// @param {Struct.RegionData} _region Region data (optional, for region-specific density)
    /// @param {Real} _seed World seed
    /// @returns {Real} Density value (positive = solid, negative = air)
    static get_density = function(_x, _y, _region = undefined, _seed = 0)
    {
        // Get region-specific settings or use defaults
        var _terrain = (_region != undefined) ? _region.get_terrain() : undefined;
        
        var _surface_y = (_terrain != undefined) ? (_terrain[$ "base_height"] ?? ___base_surface_y) : ___base_surface_y;
        var _amplitude = (_terrain != undefined) ? (_terrain[$ "amplitude"] ?? 1.0) : 1.0;
        var _noise_scale = (_terrain != undefined) ? (_terrain[$ "noise_scale"] ?? ___noise_scale) : ___noise_scale;
        var _gradient = (_terrain != undefined) ? (_terrain[$ "gradient_strength"] ?? ___gradient_strength) : ___gradient_strength;
        
        // === Height-based gradient ===
        // Above surface = negative (air), below surface = positive (solid)
        var _height_bias = (_y - _surface_y) * _gradient;
        
        // === Fractal noise for terrain variation ===
        var _noise = ___fractal_noise(_x, _y, _noise_scale, _seed) * _amplitude;
        
        // === Final density ===
        var _density = _height_bias + _noise;
        
        return _density;
    }
    
    /// @desc Get density with cave carving applied
    /// @param {Real} _x World X
    /// @param {Real} _y World Y
    /// @param {Struct.RegionData} _region Region data
    /// @param {Real} _seed World seed
    /// @param {Real} _surface_height Precomputed surface height for cave depth check
    /// @returns {Real} Density with caves subtracted
    static get_density_with_caves = function(_x, _y, _region, _seed, _surface_height)
    {
        var _base_density = get_density(_x, _y, _region, _seed);
        
        // Only carve caves below surface
        if (_y < _surface_height) return _base_density;
        
        // Cave noise (different scale/seed for variety)
        var _cave_noise = ___cave_noise(_x, _y, _seed);
        
        // Subtract caves from density (caves where noise is high)
        return _base_density - _cave_noise;
    }
    
    /// @desc Estimate surface height at X (for tree placement, etc.)
    /// Uses binary search to find where density crosses 0
    /// @param {Real} _x World X
    /// @param {Struct.RegionData} _region Region data
    /// @param {Real} _seed World seed
    /// @returns {Real} Estimated Y of surface
    static get_surface_height = function(_x, _region = undefined, _seed = 0)
    {
        // Get region base height as starting point
        var _terrain = (_region != undefined) ? _region.get_terrain() : undefined;
        var _base_y = (_terrain != undefined) ? (_terrain[$ "base_height"] ?? ___base_surface_y) : ___base_surface_y;
        
        // Binary search for surface (where density crosses 0)
        var _min_y = _base_y - 200;
        var _max_y = _base_y + 200;
        
        for (var i = 0; i < 8; i++) // 8 iterations for ~1 block precision
        {
            var _mid_y = (_min_y + _max_y) / 2;
            var _density = get_density(_x, _mid_y, _region, _seed);
            
            if (_density > 0)
            {
                _max_y = _mid_y; // Surface is above
            }
            else
            {
                _min_y = _mid_y; // Surface is below
            }
        }
        
        return floor((_min_y + _max_y) / 2);
    }
    
    /// @desc Internal: Fractal (FBM) noise
    static ___fractal_noise = function(_x, _y, _scale, _seed)
    {
        var _total = 0;
        var _amplitude = 1.0;
        var _frequency = _scale;
        var _max_value = 0;
        
        for (var i = 0; i < ___noise_octaves; i++)
        {
            _total += open_simplex_noise(_x * _frequency, _y * _frequency, _amplitude, 1);
            _max_value += _amplitude;
            _amplitude *= ___noise_persistence;
            _frequency *= ___noise_lacunarity;
        }
        
        return _total / _max_value;
    }
    
    /// @desc Internal: Cave carving noise (3D to create tunnels)
    static ___cave_noise = function(_x, _y, _seed)
    {
        // Use 2D slice of 3D noise for interesting cave shapes
        var _cave_scale = 0.03;
        var _n1 = open_simplex_noise(_x * _cave_scale, _y * _cave_scale, 1.0, 2);
        var _n2 = open_simplex_noise(_x * _cave_scale * 2 + 500, _y * _cave_scale * 2, 1.0, 2);
        
        // Combine for Swiss-cheese caves
        var _combined = (_n1 * _n1 + _n2 * _n2);
        
        // Threshold: only carve where noise is very high
        var _cave_threshold = 0.6;
        if (_combined > _cave_threshold)
        {
            return (_combined - _cave_threshold) * 3.0; // Amplify cave strength
        }
        return 0;
    }
}
