function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed, _world_data = undefined, _biome_data = undefined)
{
    // Get world data for bedrock/lava calculations
    _world_data ??= global.world_data[$ global.current_world.dimension];
    _biome_data ??= global.biome_data;
    
    var _world_height = _world_data.get_world_height();
    
    // Bedrock layer: bottom 3 tiles with randomized edges
    var _bedrock_depth = _world_height - _y;
    if (_bedrock_depth <= _world_data.get_bedrock_depth())
    {
        if (_bedrock_depth <= 1) return "phantasia:bedrock";
        
        // Use noise for ragged bedrock edge
        var _bedrock_noise = open_simplex_noise(_x * _world_data.get_bedrock_noise_scale(), _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4) return "phantasia:bedrock";
    }
    
    if (_y < _surface_height) return TILE_EMPTY;
    
    /* generate noise value (0..255) for coherent tile variation */
    var _tile_noise_scale = _world_data.get_tile_variation_noise_scale();
    var _noise = open_simplex_noise(_x * _tile_noise_scale, _y * _tile_noise_scale + (_seed / 1_000_000 * 100), 255, 2);
    
    // Cave biome tiles
    if (_cave_biome != undefined)
    {
        var _cb = _biome_data[$ worldgen_resolve_id(_cave_biome)];
        
        if (_cb != undefined)
        {
            var _custom_scale = _cb.get_tile_middle_layer_noise_scale();
            
            if (_custom_scale != undefined)
            {
                _noise = open_simplex_noise(_x * _custom_scale, _y * _custom_scale + (_seed / 1_000_000 * 100), 255, 2);
            }
            
            return _cb.get_tile_middle_layer_base(_noise);
        }
    }
    
    // Fallback if underground but no cave biome found
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
        var _default_caves_length = _world_data.get_cave_biome_default_length();
        
        if (_default_caves_length > 0)
        {
            return _biome_data[$ worldgen_resolve_id(_world_data.get_cave_biome_default()[_default_caves_length - 1].id)]
                .get_tile_middle_layer_base(_noise);
        }
    }
    
    var _sb = _biome_data[$ worldgen_resolve_id(_surface_biome)];
    
    if (_cave_above)
    {
        var _custom_scale = _sb.get_tile_top_layer_noise_scale();
        
        if (_custom_scale != undefined)
        {
            _noise = open_simplex_noise(_x * _custom_scale, _y * _custom_scale + (_seed / 1_000_000 * 100), 255, 2);
        }
        
        return _sb.get_tile_top_layer_base(_noise);
    }
    
    var _custom_scale = _sb.get_tile_middle_layer_noise_scale();
    
    if (_custom_scale != undefined)
    {
        _noise = open_simplex_noise(_x * _custom_scale, _y * _custom_scale + (_seed / 1_000_000 * 100), 255, 2);
    }
    
    return _sb.get_tile_middle_layer_base(_noise);
}
