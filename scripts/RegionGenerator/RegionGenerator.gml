/// @desc Zone Generator with 2D Voronoi + Domain Warping
/// @description Divides the world into distinct geographic regions (Zones)
///              using 3D noise to distort boundaries for natural appearance.

function RegionGenerator(_config = {}) constructor
{
    // Configuration with defaults
    ___cell_size = _config[$ "cell_size"] ?? 256;
    ___warp_scale = _config[$ "warp_scale"] ?? 0.008;
    ___warp_power = _config[$ "warp_power"] ?? 48;
    ___warp_z_scale = _config[$ "warp_z_scale"] ?? 0.015; // Z-axis contributes to warping
    ___regions = _config[$ "regions"] ?? [];
    ___region_count = array_length(___regions);
    ___seed_offset = _config[$ "seed_offset"] ?? 0;
    
    /// @desc Set regions data array
    /// @param {Array<Struct.RegionData>} _regions Array of RegionData structs
    static set_regions = function(_regions)
    {
        ___regions = _regions;
        ___region_count = array_length(_regions);
        return self;
    }
    
    /// @desc Get region at world position using warped 2D Voronoi
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position (used for warping only)
    /// @param {Real} _seed World seed
    /// @returns {Struct.RegionData} The RegionData for this position
    static get_region = function(_x, _y, _z, _seed)
    {
        // Domain warping using 2D simplex noise for organic boundaries
        var _warp_x = open_simplex_noise(
            _x * ___warp_scale,
            _y * ___warp_scale,
            1.0,
            2
        ) * ___warp_power;
        
        var _warp_y = open_simplex_noise(
            _x * ___warp_scale + 1000,
            _y * ___warp_scale + 1000,
            1.0,
            2
        ) * ___warp_power;
        
        // Apply warping to coordinates for Voronoi lookup
        var _wx = _x + _warp_x;
        var _wy = _y + _warp_y;
        
        // Find nearest region cell center via Voronoi
        return ___voronoi_lookup(_wx, _wy, _seed);
    }
    
    /// @desc Get region ID at position (faster, returns index only)
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position
    /// @param {Real} _seed World seed
    /// @returns {Real} Region index
    static get_region_id = function(_x, _y, _z, _seed)
    {
        var _warp_x = open_simplex_noise(_x * ___warp_scale, _y * ___warp_scale, 1.0, 2) * ___warp_power;
        var _warp_y = open_simplex_noise(_x * ___warp_scale + 1000, _y * ___warp_scale + 1000, 1.0, 2) * ___warp_power;
        
        var _wx = _x + _warp_x;
        var _wy = _y + _warp_y;
        
        return ___voronoi_lookup_id(_wx, _wy, _seed);
    }
    
    /// @desc 2D Voronoi cell lookup returning RegionData
    /// @private
    static ___voronoi_lookup = function(_x, _y, _seed)
    {
        var _region_id = ___voronoi_lookup_id(_x, _y, _seed);
        
        if (___region_count <= 0) return undefined;
        
        if (_region_id < 0 || _region_id >= ___region_count)
        {
            return ___regions[0]; // Fallback to first region
        }
        
        return ___regions[_region_id];
    }
    
    /// @desc 2D Voronoi cell lookup returning region index
    /// @private
    static ___voronoi_lookup_id = function(_x, _y, _seed)
    {
        // Find which cell we're in
        var _cell_x = floor(_x / ___cell_size);
        var _cell_y = floor(_y / ___cell_size);
        
        var _best_dist = infinity;
        var _best_region_id = 0;
        
        // Check this cell and 8 neighbors
        for (var _cx = _cell_x - 1; _cx <= _cell_x + 1; _cx++)
        {
            for (var _cy = _cell_y - 1; _cy <= _cell_y + 1; _cy++)
            {
                // Generate deterministic cell center
                var _cell_seed = abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ (_seed + ___seed_offset);
                
                // Jitter: random offset within cell for the Voronoi point
                var _jitter_x = frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8 + 0.1;
                var _jitter_y = frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8 + 0.1;
                
                var _point_x = (_cx + _jitter_x) * ___cell_size;
                var _point_y = (_cy + _jitter_y) * ___cell_size;
                
                // Calculate squared distance to this cell's point
                var _dx = _x - _point_x;
                var _dy = _y - _point_y;
                var _dist_sq = _dx * _dx + _dy * _dy;
                
                if (_dist_sq < _best_dist)
                {
                    _best_dist = _dist_sq;
                    // Determine which region this cell belongs to
                    _best_region_id = abs(_cell_seed) mod ___region_count;
                }
            }
        }
        
        return _best_region_id;
    }
    
    /// @desc Get distance to nearest region boundary (for blending)
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position
    /// @param {Real} _seed World seed
    /// @returns {Real} Distance to nearest zone boundary
    static get_boundary_distance = function(_x, _y, _z, _seed)
    {
        var _warp_x = open_simplex_noise(_x * ___warp_scale, _y * ___warp_scale, 1.0, 2) * ___warp_power;
        var _warp_y = open_simplex_noise(_x * ___warp_scale + 1000, _y * ___warp_scale + 1000, 1.0, 2) * ___warp_power;
        
        var _wx = _x + _warp_x;
        var _wy = _y + _warp_y;
        
        var _cell_x = floor(_wx / ___cell_size);
        var _cell_y = floor(_wy / ___cell_size);
        
        var _best_dist = infinity;
        var _second_best_dist = infinity;
        
        for (var _cx = _cell_x - 1; _cx <= _cell_x + 1; _cx++)
        {
            for (var _cy = _cell_y - 1; _cy <= _cell_y + 1; _cy++)
            {
                var _cell_seed = abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ (_seed + ___seed_offset);
                
                var _jitter_x = frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8 + 0.1;
                var _jitter_y = frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8 + 0.1;
                
                var _point_x = (_cx + _jitter_x) * ___cell_size;
                var _point_y = (_cy + _jitter_y) * ___cell_size;
                
                var _dx = _wx - _point_x;
                var _dy = _wy - _point_y;
                var _dist = sqrt(_dx * _dx + _dy * _dy);
                
                if (_dist < _best_dist)
                {
                    _second_best_dist = _best_dist;
                    _best_dist = _dist;
                }
                else if (_dist < _second_best_dist)
                {
                    _second_best_dist = _dist;
                }
            }
        }
        
        // Distance to boundary is approximately half the difference
        return (_second_best_dist - _best_dist) / 2.0;
    }
    
    /// @desc Get data for blending between regions
    /// @param {Real} _x World X position
    /// @param {Real} _y World Y position
    /// @param {Real} _z World Z position
    /// @param {Real} _seed World seed
    /// @returns {Struct} { r1: RegionData, r2: RegionData, factor: Real }
    static get_blend_data = function(_x, _y, _z, _seed)
    {
        var _warp_x = open_simplex_noise(_x * ___warp_scale, _y * ___warp_scale, 1.0, 2) * ___warp_power;
        var _warp_y = open_simplex_noise(_x * ___warp_scale + 1000, _y * ___warp_scale + 1000, 1.0, 2) * ___warp_power;
        
        var _wx = _x + _warp_x;
        var _wy = _y + _warp_y;
        
        var _cell_x = floor(_wx / ___cell_size);
        var _cell_y = floor(_wy / ___cell_size);
        
        var _best_dist = infinity;
        var _second_best_dist = infinity;
        var _best_region_id = 0;
        var _second_best_region_id = 0;
        
        for (var _cx = _cell_x - 1; _cx <= _cell_x + 1; _cx++)
        {
            for (var _cy = _cell_y - 1; _cy <= _cell_y + 1; _cy++)
            {
                var _cell_seed = abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ (_seed + ___seed_offset);
                
                var _jitter_x = frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8 + 0.1;
                var _jitter_y = frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8 + 0.1;
                
                var _point_x = (_cx + _jitter_x) * ___cell_size;
                var _point_y = (_cy + _jitter_y) * ___cell_size;
                
                var _dx = _wx - _point_x;
                var _dy = _wy - _point_y;
                var _dist_sq = _dx * _dx + _dy * _dy;
                // Avoid sqrt for comparison if possible, but we need linear dist for blending math usually.
                // Standard Voronoi F2-F1 uses linear distance.
                var _dist = sqrt(_dist_sq);
                
                var _region_id = abs(_cell_seed) mod ___region_count;
                
                if (_dist < _best_dist)
                {
                    _second_best_dist = _best_dist;
                    _second_best_region_id = _best_region_id;
                    _best_dist = _dist;
                    _best_region_id = _region_id;
                }
                else if (_dist < _second_best_dist)
                {
                    _second_best_dist = _dist;
                    _second_best_region_id = _region_id;
                }
            }
        }
        
        var _r1 = ___regions[_best_region_id];
        var _r2 = ___regions[_second_best_region_id];
        
        // F2 - F1. 
        // If 0, we are at edge. If large, we are deep inside cell.
        // We want factor = 0 when deep in r1, 0.5 at edge?
        // Actually, for simple linear blend:
        // factor = 0.5 - (d2-d1)/(2*width)?
        //
        // Common approach:
        // edge_dist = (d2 - d1) / 2
        //
        // We return just d2 - d1 for flexibility.
        
        return {
            r1: _r1,
            r2: _r2,
            diff: _second_best_dist - _best_dist
        };
    }
}
