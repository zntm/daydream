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
    
    // Map Buffer Support
    ___map_buffer = _config[$ "map_buffer"];
    ___map_width = _config[$ "map_width"] ?? 0;
    ___map_height = _config[$ "map_height"] ?? 0;
    
    // Build color lookup table for regions
    ___map_color_to_region = {};
    for (var i = 0; i < ___region_count; ++i)
    {
        var _r = ___regions[i];
        var _color = _r.get_map_color();
        // Store both as number and string for robustness
        ___map_color_to_region[$ string(_color)] = _r;
        ___map_color_to_region[$ _color] = _r;
    }
    
    /// @desc Set regions data array
    /// @param {Array<Struct.RegionData>} _regions Array of RegionData structs
    static set_regions = function(_regions)
    {
        ___regions = _regions;
        ___region_count = array_length(_regions);
        
        // Re-build lookup table
        ___map_color_to_region = {};
        for (var i = 0; i < ___region_count; ++i)
        {
            var _r = ___regions[i];
            var _color = _r.get_map_color();
            ___map_color_to_region[$ string(_color)] = _r;
            ___map_color_to_region[$ _color] = _r;
        }
        
        return self;
    }
    
    /// @desc Get region from map buffer using world coordinates
    /// @private
    static ___get_region_from_map = function(_x, _y)
    {
        if (___map_buffer == undefined) return undefined;
        
        // Map world coordinate to pixel coordinate
        // Assuming 1 pixel = ___cell_size in world space
        var _px = floor(_x / ___cell_size);
        var _py = floor(_y / ___cell_size);
        
        // Clamp to map boundaries
        _px = clamp(_px, 0, ___map_width - 1);
        _py = clamp(_py, 0, ___map_height - 1);
        
        // Sample buffer (RGBA format)
        var _pos = (_py * ___map_width + _px) * 4;
        var _r = buffer_peek(___map_buffer, _pos,     buffer_u8);
        var _g = buffer_peek(___map_buffer, _pos + 1, buffer_u8);
        var _b = buffer_peek(___map_buffer, _pos + 2, buffer_u8);
        
        // Convert to GML color (BGR)
        var _color = (_b << 16) | (_g << 8) | _r;
        
        var _region = ___map_color_to_region[$ _color];
        if (_region == undefined)
        {
             // Try string key lookup
             _region = ___map_color_to_region[$ string(_color)];
        }
        
        static _count = 0;
        if (_count < 10)
        {
            _count++;
            show_debug_message($"RegionGenerator: Map Lookup at ({_x}, {_y}) -> Pixel ({_px}, {_py}), Color: {ptr(_color)}, Region: {(_region != undefined ? _region.get_id() : "NONE")}");
        }
        
        return _region;
    }
    
    /// @desc Get region at world position
    static get_region = function(_x, _y, _z, _seed)
    {
        // 1. Try Map Image Lookup First
        var _map_region = ___get_region_from_map(_x, _y);
        if (_map_region != undefined) return _map_region;
        
        // 2. Fallback to Domain warped Voronoi
        var _warp_x = open_simplex_noise(_x * ___warp_scale, _y * ___warp_scale, 1.0, 2) * ___warp_power;
        var _warp_y = open_simplex_noise(_x * ___warp_scale + 1000, _y * ___warp_scale + 1000, 1.0, 2) * ___warp_power;
        
        var _wx = _x + _warp_x;
        var _wy = _y + _warp_y;
        
        return ___voronoi_lookup(_wx, _wy, _seed);
    }
    
    /// @desc Get region ID at position (faster, returns index only)
    static get_region_id = function(_x, _y, _z, _seed)
    {
        var _map_region = ___get_region_from_map(_x, _y);
        if (_map_region != undefined)
        {
            for (var i = 0; i < ___region_count; ++i)
            {
                if (___regions[i] == _map_region) return i;
            }
        }
        
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
    static get_boundary_distance = function(_x, _y, _z, _seed)
    {
        if (___map_buffer != undefined) return 1000; // No blending for map-based lookups yet
        
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
        
        return (_second_best_dist - _best_dist) / 2.0;
    }
    
    /// @desc Get data for blending between regions
    static get_blend_data = function(_x, _y, _z, _seed)
    {
        var _map_region = ___get_region_from_map(_x, _y);
        if (_map_region != undefined)
        {
            return {
                r1: _map_region,
                r2: _map_region,
                diff: 1000
            };
        }
        
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
        
        return {
            r1: _r1,
            r2: _r2,
            diff: _second_best_dist - _best_dist
        };
    }
}
