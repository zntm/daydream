function worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _top_tile, _surface_height, _seed)
{
    var _biome_id = _cave_biome;
    
    // Priority: At or above surface layer, use surface biome
    if (_y <= _surface_height)
    {
        _biome_id = _surface_biome;
        
        var _world_data = global.world_data[$ global.world_save_data.dimension];
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
                    if (is_string(_new_id)) _biome_id = _new_id;
                }
                else if (_blend_noise > 0.2 && (_heat_right != _heat || _humidity_right != _humidity))
                {
                    var _new_id = _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right];
                    if (is_string(_new_id)) _biome_id = _new_id;
                }
            }
        }
    }
    else if (_biome_id == undefined)
    {
        // Underground but no cave biome? return empty
        return TILE_EMPTY;
    }

    var _foliage = global.biome_data[$ _biome_id];
    
    // Safety check
    if (_foliage == undefined) return TILE_EMPTY;
    
    // Check for MaterialProvider-based foliage
    var _provider = _foliage.get_tile_foliage();
    
    if (_provider != undefined)
    {
        var _noise = open_simplex_noise(_x * 0.1, _y * 0.1 + (_seed * 200), 1.0, 1);
        var _context = {
            x: _x, y: _y, surface_height: _surface_height, noise: _noise, top_tile: _top_tile,
            cave_above: true,
            air_above: 1,
            cave_biome: _cave_biome
        }
        return _provider.get_tile(_context);
    }

    return TILE_EMPTY;
}
