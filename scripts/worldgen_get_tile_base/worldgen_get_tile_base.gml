/// @desc Get base tile for terrain generation
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {String} _surface_biome Surface biome ID
/// @param {String} _cave_biome Cave biome ID (or undefined)
/// @param {Real} _surface_height Surface height at this position
/// @param {Bool} _cave_above Whether there is a cave above this position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data Optional: World data struct
/// @param {Struct} _biome_data Optional: Biome data struct
/// @returns {String} Tile ID
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
    
    // Generate noise value (0..1) for coherent tile variation
    var _tile_noise_scale = _world_data.get_tile_variation_noise_scale();
    var _noise = open_simplex_noise(_x * _tile_noise_scale, _y * _tile_noise_scale + (_seed * 100), 1.0, 2);
    
    // Cave biome tiles
    if (_cave_biome != undefined)
    {
        var _cb = _biome_data[$ worldgen_resolve_id(_cave_biome)];
        if (_cb != undefined) return _cb.get_tile_middle_layer_base(_noise);
    }
    
    // Fallback if underground but no cave biome found
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
        var _default_caves = _world_data.get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome = worldgen_resolve_id(_default_caves[array_length(_default_caves) - 1].id); 
            var _cb = _biome_data[$ _def_biome];
            if (_cb != undefined) return _cb.get_tile_middle_layer_base(_noise);
        }
    }
    
    // Surface tiles
    var _sb = _biome_data[$ worldgen_resolve_id(_surface_biome)];
    if (_sb == undefined) return TILE_EMPTY;
    
    return _cave_above ? _sb.get_tile_top_layer_base(_noise) : _sb.get_tile_middle_layer_base(_noise);
}
