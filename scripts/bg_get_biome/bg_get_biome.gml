function bg_get_biome(_x, _y, _surface_height = undefined)
{
    var _world_save_data = global.world_save_data;
    
    var _seed = _world_save_data.seed;
    
    _surface_height ??= worldgen_get_surface_height(_x, _seed);
     
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    // Check for sky biome first (highest priority)
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    
    if (_y <= _sky_threshold && _world_data.is_sky_biome_enabled())
    {
        if (worldgen_get_sky_island(_x, _y, _seed, _world_data))
        {
            return _world_data.get_sky_biome_id();
        }
    }
    
    // Check for cave biome (consistent with worldgen_get_biome_cave's 8-block buffer)
    if (_y > _surface_height + 8)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _seed);
        
        if (_cave_biome != undefined)
        {
            return _cave_biome;
        }
    }
    
    // Use Region system for surface biome (consistent with chunk_generate)
    var _region = global.region_generator.get_region(_x, 0, 0, _seed);
    var _surface_biome_id = _region.get_surface_biome_id();

    var _blend_range = _world_data.get_biome_blend_range();
    var _blend_noise_scale = _world_data.get_biome_blend_noise_scale();
    
    var _heat = worldgen_get_heat(_x, 0, _seed, _world_data);
    var _humidity = worldgen_get_humidity(_x, 0, _seed, _world_data);
    var _heat_left = worldgen_get_heat(_x - _blend_range, 0, _seed, _world_data);
    var _heat_right = worldgen_get_heat(_x + _blend_range, 0, _seed, _world_data);
    var _humidity_left = worldgen_get_humidity(_x - _blend_range, 0, _seed, _world_data);
    var _humidity_right = worldgen_get_humidity(_x + _blend_range, 0, _seed, _world_data);
    
    var _is_boundary = (_heat != _heat_left) || (_heat != _heat_right) || 
                       (_humidity != _humidity_left) || (_humidity != _humidity_right);
    
    if (_is_boundary)
    {
        var _blend_noise = open_simplex_noise(_x * _blend_noise_scale, _y * _blend_noise_scale + 1000, 1.0, 2);
        if (_blend_noise > 0.2)
        {
            var _surface_biome_map = _world_data.get_surface_biome_map();
            if (_blend_noise > 0.55 && (_heat_left != _heat || _humidity_left != _humidity))
            {
                var _new_id = _surface_biome_map[(_humidity_left << WORLDGEN_SIZE_HEAT_BIT) | _heat_left];
                if (is_string(_new_id)) return _new_id;
            }
            else if (_blend_noise > 0.2 && (_heat_right != _heat || _humidity_right != _humidity))
            {
                var _new_id = _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right];
                if (is_string(_new_id)) return _new_id;
            }
        }
    }

    return _surface_biome_id;
}