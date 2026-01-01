function worldgen_get_cave(_x, _y, _surface_height, _cave_start, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    // Surface breach zone: allow caves to occasionally breach the surface
    var _depth_from_surface = _y - _surface_height;
    
    // Above surface - check for surface breach openings
    if (_depth_from_surface < 0)
    {
        // Only allow breaches within a reasonable range above surface (8 tiles)
        if (_depth_from_surface > _world_data.get_cave_breach_depth())
        {
            // Use separate noise for surface breaching (low frequency, rare occurrence)
            var _breach_noise = open_simplex_noise(_x * _world_data.get_cave_breach_noise_scale_x(), _surface_height * _world_data.get_cave_breach_noise_scale_y() + _world_data.get_cave_breach_noise_offset_y(), _world_data.get_cave_breach_noise_range(), _world_data.get_cave_breach_noise_octaves());
            
            // ~5% chance of surface breach (threshold ~242 out of 255)
            if (_breach_noise > _world_data.get_cave_breach_threshold())
            {
                // Check if there's an actual cave below to connect to
                var _cave_below = worldgen_get_cave(_x, _surface_height + 2, _surface_height, _cave_start, _seed, _world_data);
                if (_cave_below)
                {
                    return true; // This is a surface breach opening
                }
            }
        }
        return true; // Above surface, no block (sky)
    }
    
    // Transition zone near surface - caves can exist but with reduced probability
    if (_depth_from_surface < _cave_start + _world_data.get_cave_start_min())
    {
        // Gradual transition: deeper = more likely to have caves
        var _transition_factor = _depth_from_surface / (_cave_start + _world_data.get_cave_start_min());
        var _transition_noise = open_simplex_noise(_x * _world_data.get_cave_transition_noise_scale_x(), _y * _world_data.get_cave_transition_noise_scale_y(), _world_data.get_cave_transition_noise_range(), _world_data.get_cave_transition_noise_octaves());
        
        // Require higher noise values near surface
        if (_transition_noise < (_world_data.get_cave_transition_threshold() * (1 - _transition_factor)))
        {
            return false;
        }
    }
    
    var _system = _world_data.get_cave_system();
    var _system_length = _world_data.get_cave_system_length();
    
    var _x_noise = _x * _world_data.get_cave_noise_scale();
    var _y_noise = _y * _world_data.get_cave_noise_scale();
    
    for (var i = 0; i < _system_length; ++i)
    {
        var _ = _system[i];
        
        var _octaves = _.threshold.octaves;
        
        var _noise = open_simplex_noise(_x_noise, _y_noise + ((0xffff * (i + 1)) + 8), 0xff, _octaves);
        
        if (_noise >= _.range_min) && (_noise < _.range_max)
        {
            return true;
        }
    }
    
    return false;
}