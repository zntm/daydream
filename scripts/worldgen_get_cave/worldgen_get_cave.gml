function worldgen_get_cave(_x, _y, _surface_height, _cave_start, _seed, _world_data = global.world_data[$ global.current_world.dimension], _cave_below = undefined)
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
                var _is_cave_below = (_cave_below != undefined) ? _cave_below : worldgen_get_cave(_x, _surface_height + 2, _surface_height, _cave_start, _seed, _world_data);
                
                if (_is_cave_below)
                {
                    return true; // This is a surface breach opening
                }
            }
        }
        return true; // Above surface, no block (sky)
    }
    
    // Calculate depth smoothing factor using spline interpolation
    // Factor ranges from 0 (near surface) to 1 (at full depth)
    var _depth_smoothing = _world_data.get_cave_depth_smoothing();
    var _depth_factor = spline_evaluate(_depth_smoothing, _depth_from_surface);
    
    // If depth factor is 0, no caves at this depth
    if (_depth_factor <= 0)
    {
        return false;
    }

    // Keep aquifer roofs open, but stop cave carving through the retaining shell
    // around the filled portion so the water has solid sides and bottom.
    var _aquifer_region = worldgen_get_aquifer(_x, _y, _surface_height, _seed, _world_data, true);
    if (_aquifer_region != undefined)
    {
        if (_aquifer_region.is_containment_shell)
        {
            return false;
        }

        return true;
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
        
        // Apply depth smoothing: shrink the valid range near surface
        // This makes caves smaller/rarer near surface and larger/more common deeper
        var _range_center = (_.range_min + _.range_max) / 2;
        var _range_half = ((_.range_max - _.range_min) / 2) * _depth_factor;
        var _smoothed_min = _range_center - _range_half;
        var _smoothed_max = _range_center + _range_half;
        
        if (_noise >= _smoothed_min) && (_noise < _smoothed_max)
        {
            return true;
        }
    }
    
    return false;
}
