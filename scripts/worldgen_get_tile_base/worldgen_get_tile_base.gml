/// @desc Get base tile for terrain generation with horizontal biome blending
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {String} _surface_biome Surface biome ID
/// @param {String} _cave_biome Cave biome ID (or undefined)
/// @param {Real} _surface_height Surface height at this position
/// @param {Bool} _cave_above Whether there is a cave above this position
/// @param {Real} _seed World seed
/// @returns {String} Tile ID
/// @desc Get base tile for terrain generation with horizontal biome blending
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {String} _surface_biome Surface biome ID
/// @param {String} _cave_biome Cave biome ID (or undefined)
/// @param {Real} _surface_height Surface height at this position
/// @param {Bool} _cave_above Whether there is a cave above this position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data Optional: World data struct
/// @param {Struct} _biome_data Optional: Biome data struct
/// @param {Real} _heat Optional: Pre-calculated heat value
/// @param {Real} _humidity Optional: Pre-calculated humidity value
/// @returns {String} Tile ID
function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed, _world_data = undefined, _biome_data = undefined, _heat = undefined, _humidity = undefined)
{
    // Get world data for bedrock/lava calculations
    _world_data ??= global.world_data[$ global.world_save_data.dimension];
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
    
    // Cave biome tiles (no horizontal blending for underground)
    if (_cave_biome != undefined)
    {
        var _cb = _biome_data[$ _cave_biome];
        if (_cb != undefined) return _cb.get_tile_middle_layer_base(_noise);
    }
    
    // Fallback if underground but no cave biome found
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
        var _default_caves = _world_data.get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome = _default_caves[array_length(_default_caves) - 1].id; 
            var _cb = _biome_data[$ _def_biome];
            if (_cb != undefined) return _cb.get_tile_middle_layer_base(_noise);
        }
    }
    
    // Surface biome tiles with horizontal blending
    var _blend_range = _world_data.get_biome_blend_range();
    
    // Use pre-calculated params if available, otherwise fetch them (slow)
    _heat ??= worldgen_get_heat(_x, _surface_height, _seed, _world_data);
    _humidity ??= worldgen_get_humidity(_x, _surface_height, _seed, _world_data);
    
    var _heat_left = worldgen_get_heat(_x - _blend_range, _surface_height, _seed, _world_data);
    var _heat_right = worldgen_get_heat(_x + _blend_range, _surface_height, _seed, _world_data);
    var _humidity_left = worldgen_get_humidity(_x - _blend_range, _surface_height, _seed, _world_data);
    var _humidity_right = worldgen_get_humidity(_x + _blend_range, _surface_height, _seed, _world_data);
    
    var _is_boundary = (_heat != _heat_left) || (_heat != _heat_right) || 
                       (_humidity != _humidity_left) || (_humidity != _humidity_right);
    
    var _biome_to_use = _surface_biome;
    
    if (_is_boundary)
    {
        var _blend_noise_scale = _world_data.get_biome_blend_noise_scale();
        var _blend_noise = open_simplex_noise(_x * _blend_noise_scale, _y * _blend_noise_scale + 1000, 1.0, 2);
        
        if (_blend_noise > 0.2)
        {
            var _surface_biome_map = _world_data.get_surface_biome_map();
            
            if (_blend_noise > 0.55 && (_heat_left != _heat || _humidity_left != _humidity))
            {
                _biome_to_use = _surface_biome_map[(_humidity_left << WORLDGEN_SIZE_HEAT_BIT) | _heat_left];
            }
            else if (_blend_noise > 0.2 && (_heat_right != _heat || _humidity_right != _humidity))
            {
                _biome_to_use = _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right];
            }
        }
    }
    
    var _sb = _biome_data[$ _biome_to_use];
    if (_sb == undefined) return TILE_EMPTY;
    
    return _cave_above ? _sb.get_tile_top_layer_base(_noise) : _sb.get_tile_middle_layer_base(_noise);
}
