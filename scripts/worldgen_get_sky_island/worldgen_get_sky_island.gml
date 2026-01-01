/// @desc Returns true if the given position is part of a floating sky island
/// @param {Real} _x World X position
/// @param {Real} _y World Y position  
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Bool} True if this position should be solid sky island
function worldgen_get_sky_island(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    // Check if sky biome is enabled
    if (!_world_data.is_sky_biome_enabled())
    {
        return false;
    }
    
    // Sky biome exists in the y range 0 to threshold (configurable per-world)
    var _sky_min = 0;
    var _sky_max = _world_data.get_sky_biome_threshold();
    
    if (_y < _sky_min) || (_y > _sky_max)
    {
        return false;
    }
    
    // Island center detection using cellular/voronoi-like approach
    var _island_spacing = _world_data.get_sky_island_spacing();    // Distance between potential island centers (smaller = more common)
    var _island_max_radius = _world_data.get_sky_island_radius(); // Maximum island radius
    var _island_thickness = _world_data.get_sky_island_thickness();  // Vertical thickness at center
    
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
            
            // More islands - lower threshold for region check
            var _region = open_simplex_noise(_cx * _world_data.get_sky_noise_scale_region(), _cy * _world_data.get_sky_noise_scale_region() + _world_data.get_sky_region_offset_y(), _world_data.get_sky_region_range(), _world_data.get_sky_region_octaves());
            if (_region < _world_data.get_sky_region_threshold()) continue; // Lower = more islands
            
            // Random offset within cell for island center
            var _island_x = (_cx + 0.2 + frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.6) * _island_spacing;
            var _island_y = (_cy + 0.2 + frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.6) * _island_spacing;
            
            // Random size variation per island
            var _size_factor = 0.5 + frac(sin(_cell_seed * 0.0003) * 12345.6789) * 0.7;
            var _this_radius = _island_max_radius * _size_factor;
            var _this_thickness = _island_thickness * _size_factor;
            
            // Calculate distance from island center
            var _dx = _x - _island_x;
            var _dy = _y - _island_y;
            
            // Elliptical distance (flatter islands - wider than tall)
            var _horizontal_dist = abs(_dx) / _this_radius;
            var _vertical_dist = abs(_dy) / (_this_thickness * 0.5);
            
            // Basic island shape - rounded top, pointed bottom
            if (_dy < 0)
            {
                // Above center - rounder top
                _vertical_dist *= 0.6;
            }
            else
            {
                // Below center - more tapered bottom
                _vertical_dist *= 1.3;
            }
            
            var _dist = sqrt(_horizontal_dist * _horizontal_dist + _vertical_dist * _vertical_dist);
            
            // ROUGHER edges - more noise amplitude and higher frequency
            var _edge_noise = open_simplex_noise(_x * _world_data.get_sky_noise_scale_edge(), _y * _world_data.get_sky_noise_scale_edge() + _cell_seed * 0.001, _world_data.get_sky_edge_noise_amplitude(), _world_data.get_sky_edge_noise_octaves());
            var _detail_noise = open_simplex_noise(_x * _world_data.get_sky_noise_scale_detail(), _y * _world_data.get_sky_noise_scale_detail() + _cell_seed * 0.002, _world_data.get_sky_detail_noise_amplitude(), _world_data.get_sky_detail_noise_octaves());
            
            if (_dist < 1.0 + _edge_noise + _detail_noise)
            {
                return true;
            }
        }
    }
    
    return false;
}
