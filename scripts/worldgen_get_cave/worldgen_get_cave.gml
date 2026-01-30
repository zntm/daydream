function worldgen_get_cave(_x, _y, _surface_height, _cave_seed, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _cave_density_modifier = 1.0, _squash = 1.0)
{
    var _depth = _y - _surface_height;
    if (_depth < 5) return false;
    
    var _systems = _world_data.get_cave_systems();
    var _count = _world_data.get_cave_systems_length();
    
    for (var i = 0; i < _count; ++i)
    {
        var _sys = _systems[i];
        
        // Check depth range
        if (_depth < _sys.range_min || _depth > _sys.range_max) continue;
        
        // Check noise
        var _noise_conf = _sys.threshold;
        var _scale = 0.02; // Default scale per system? or hardcoded? Using default for now
        
        // Note: Noise object in worlds.ts has {octaves, range_min, range_max}. 
        // We use it as a threshold rule here: if noise > threshold, it's a cave.
        // Actually, the user object is `WorldCaveSystem(rangeMin, rangeMax, threshold: Noise)`.
        // Let's assume threshold.range_min is the cutoff value (0-255 usually, need to normalize).
        
        var _threshold_val = (_noise_conf.range_min / 255.0) / _cave_density_modifier;
        
        // Generate noise value with squash applied to Y
        var _n = open_simplex_noise(_x * _scale, (_y * _squash) * _scale, _seed, _noise_conf.octaves);
        
        // Normalize noise -1..1 to 0..1
        var _n_norm = (_n + 1) * 0.5;
        
        if (_n_norm > _threshold_val)
        {
            return true;
        }
    }
    
    return false;
}
