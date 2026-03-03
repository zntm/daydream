function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed, _world_data = undefined, _biome_data = undefined)
{
    if (_y < _surface_height) return TILE_EMPTY;
    
    _world_data ??= global.world_data[$ global.current_world.dimension];
    _biome_data ??= global.biome_data;
    
    /* generate noise value (0..255) for coherent tile variation */
    /* offset differently from base tiles to avoid identical patterns */
    var _tile_noise_scale = _world_data.get_tile_variation_noise_scale();
    var _noise = open_simplex_noise(_x * _tile_noise_scale, _y * _tile_noise_scale + (_seed * 200), 255, 2);
    
    if (_cave_biome != undefined)
    {
        var _cb = _biome_data[$ worldgen_resolve_id(_cave_biome)];
        
        if (_cb != undefined)
        {
            var _custom_scale = _cb.get_tile_middle_layer_noise_scale();
            
            if (_custom_scale != undefined)
            {
                _noise = open_simplex_noise(_x * _custom_scale, _y * _custom_scale + (_seed * 200), 255, 2);
            }
            
            return _cb.get_tile_middle_layer_wall(_noise);
        }
    }
    
    // Fallback if underground but no cave biome found
    // Respect the 8-block surface buffer
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
        // Try to get the first default cave biome
        var _default_caves = _world_data.get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome = worldgen_resolve_id(_default_caves[array_length(_default_caves) - 1].id); 
            var _cb = _biome_data[$ _def_biome];
            if (_cb != undefined) return _cb.get_tile_middle_layer_wall(_noise);
        }
    }
    
    var _sb = _biome_data[$ worldgen_resolve_id(_surface_biome)];
    if (_sb == undefined) return TILE_EMPTY;
    
    return (_y == _surface_height) ? _sb.get_tile_top_layer_wall(_noise) : _sb.get_tile_middle_layer_wall(_noise);
}