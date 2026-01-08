/// @desc Returns true if the given position is part of a floating sky island
/// @param {Real} _x World X position
/// @param {Real} _y World Y position  
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @param {Real} _surface_height Surface height (optional, for height constraints)
/// @returns {Bool} True if this position should be solid sky island
function worldgen_get_sky_island(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _surface_height = undefined)
{
    // Check if sky biome is enabled
    if (!_world_data.is_sky_biome_enabled())
    {
        return false;
    }
    
    // Island parameters
    var _island_spacing = _world_data.get_sky_island_spacing();
    var _island_max_radius = _world_data.get_sky_island_radius();
    var _island_thickness = _world_data.get_sky_island_thickness();
    var _roughness_amp = _world_data.get_sky_roughness_amplitude();
    var _roughness_scale = _world_data.get_sky_roughness_scale();
    
    // Find which island cell we're in
    var _cell_x = floor(_x / _island_spacing);
    var _cell_y = floor(_y / _island_spacing);
    
    // Check this cell and neighbors for islands
    for (var _cx = _cell_x - 1; _cx <= _cell_x + 1; _cx++)
    {
        for (var _cy = _cell_y - 1; _cy <= _cell_y + 1; _cy++)
        {
            // Generate deterministic island center for this cell
            var _cell_seed = abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ _seed;
            
            // Region check - determines if an island exists in this cell
            var _region = open_simplex_noise(_cx * _world_data.get_sky_noise_scale_region(), _cy * _world_data.get_sky_noise_scale_region() + _world_data.get_sky_region_offset_y(), _world_data.get_sky_region_range(), _world_data.get_sky_region_octaves());
            if (_region < _world_data.get_sky_region_threshold()) continue;
            
            // Random offset within cell for island center (Increased variation)
            var _island_x = (_cx + 0.1 + frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8) * _island_spacing;
            var _island_y = (_cy + 0.1 + frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8) * _island_spacing;
            
            // Height Constraint logic: "range of like 50 blocks above the surface"
            if (_surface_height != undefined)
            {
                // If the island center is too high (more than ~64 blocks above surface), skip it
                // Note: Lower Y is higher in air.
                // _surface_height is e.g. 450. _island_y must be > 390.
                if (_island_y < _surface_height - 64) continue;
                
                // Also skip if it's BELOW the surface (buried)
                if (_island_y > _surface_height - 8) continue;
            }
            
            // Random size variation per island (More varied)
            var _size_factor = 0.4 + frac(sin(_cell_seed * 0.0003) * 12345.6789) * 1.2; // 0.4 to 1.6 range
            var _this_radius = _island_max_radius * _size_factor;
            var _this_thickness = _island_thickness * _size_factor;
            
            // Calculate distance from island center
            var _dx = _x - _island_x;
            var _dy = _y - _island_y;
            
            // Elliptical distance (flatter islands - wider than tall)
            var _horizontal_dist = abs(_dx) / _this_radius;
            var _vertical_dist = abs(_dy) / (_this_thickness * 0.5);
            
            // Asymmetric vertical shape: rounder top, pointed bottom
            if (_dy < 0)
            {
                // Above center - rounder top
                _vertical_dist *= 0.5;
            }
            else
            {
                // Below center - more tapered bottom
                _vertical_dist *= 1.5;
            }
            
            var _dist = sqrt(_horizontal_dist * _horizontal_dist + _vertical_dist * _vertical_dist);
            
            // Apply roughness noise to create organic, rocky edges (Double octaves/freq for more noise)
            var _roughness_noise = (open_simplex_noise(
                _x * _roughness_scale + _cell_seed * 0.001, 
                _y * _roughness_scale, 
                1.0, 
                3
            ) * _roughness_amp) + 
            (open_simplex_noise(
                _x * (_roughness_scale * 2.5) + _cell_seed * 0.002, 
                _y * (_roughness_scale * 2.5), 
                1.0, 
                1
            ) * (_roughness_amp * 0.5));
            
            // Density-based threshold: inside island if dist < 1 + noise
            if (_dist < 1.0 + _roughness_noise)
            {
                return true;
            }
        }
    }
    
    return false;
}

/// @desc Returns true if the position is inside a wall support pillar beneath a floating island
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @param {Real} _surface_height Surface height (optional, for connecting supports)
/// @returns {Bool} True if this position is inside a support pillar
function worldgen_is_below_sky_island(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _surface_height = undefined)
{
    if (!_world_data.is_sky_biome_enabled()) return false;
    
    // Island parameters
    var _island_spacing = _world_data.get_sky_island_spacing();
    var _island_max_radius = _world_data.get_sky_island_radius();
    var _island_thickness = _world_data.get_sky_island_thickness();
    var _support_chance = _world_data.get_sky_support_chance();
    var _support_width_factor = _world_data.get_sky_support_width();
    var _support_taper = _world_data.get_sky_support_taper();
    var _support_max_length = _world_data.get_sky_support_max_length();
    
    // We only need to check the cell column we are in
    var _cell_x = floor(_x / _island_spacing);
    
    // Scan upward from current Y to find islands above
    var _start_cy = floor(_y / _island_spacing);
    
    // Optimization: if surface height is known and we are deep underground, skip?
    if (_surface_height != undefined && _y > _surface_height + 20) return false;

    var _end_cy = _start_cy - 4; // Check 4 cells up max
    
    for (var _cy = _start_cy; _cy >= _end_cy; --_cy)
    {
        for (var _cx = _cell_x - 1; _cx <= _cell_x + 1; ++_cx)
        {
            // Generate deterministic island center for this cell
            var _cell_seed = abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ _seed;
            
            // Check if island exists in this cell
            var _region = open_simplex_noise(_cx * _world_data.get_sky_noise_scale_region(), _cy * _world_data.get_sky_noise_scale_region() + _world_data.get_sky_region_offset_y(), _world_data.get_sky_region_range(), _world_data.get_sky_region_octaves());
            if (_region < _world_data.get_sky_region_threshold()) continue;
            
            // Deterministic check: does this island have a support?
            var _has_support = frac(sin(_cell_seed * 0.0004) * 98765.4321) < _support_chance;
            if (!_has_support) continue;
            
            // Calculate island center
            var _island_x = (_cx + 0.1 + frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8) * _island_spacing;
            var _island_y = (_cy + 0.1 + frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8) * _island_spacing;
            
            // Height Constraint Check (Must match worldgen_get_sky_island logic)
            if (_surface_height != undefined)
            {
                if (_island_y < _surface_height - 64) continue;
                if (_island_y > _surface_height - 8) continue;
            }
            
            // Size variation
            var _size_factor = 0.4 + frac(sin(_cell_seed * 0.0003) * 12345.6789) * 1.2;
            var _this_radius = _island_max_radius * _size_factor;
            var _this_thickness = _island_thickness * _size_factor;
            
            // Support starts at the bottom of the island
            var _support_top_y = _island_y + _this_thickness * 0.5;
            
            var _this_max_length = _support_max_length;
            
            // "The more bottom ones should always connect to the actual surface"
            // If the island is close to the surface, extend support to connect
            if (_surface_height != undefined)
            {
                // If island is within ~100 blocks of surface, force connection
                if (_support_top_y > _surface_height - 100)
                {
                    // Set max length to reach surface + embed slightly
                    _this_max_length = (_surface_height - _support_top_y) + 5;
                }
            }
            
            var _support_bottom_y = _support_top_y + _this_max_length;
            
            // Must be below the island to be in the support
            if (_y < _support_top_y || _y > _support_bottom_y) continue;
            
            // Calculate support width at this Y level (tapers as it goes down)
            var _dist_down = _y - _support_top_y;
            var _taper_factor = max(0.1, 1.0 - _dist_down * _support_taper);
            var _support_width = _this_radius * _support_width_factor * _taper_factor;
            
            // Add slight organic waviness to the support
            var _wave_noise = open_simplex_noise(_x * 0.05 + _cell_seed * 0.001, _y * 0.03, 1.0, 2) * 2;
            
            // Horizontal check - within support width
            var _dx = abs(_x - _island_x - _wave_noise);
            
            if (_dx < _support_width) 
            {
                return true;
            }
        }
    }
    
    return false;
}
