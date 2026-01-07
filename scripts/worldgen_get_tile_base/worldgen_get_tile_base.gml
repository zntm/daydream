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
/// @returns {String} Tile ID
function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed)
{
    // Get world data for bedrock/lava calculations
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    // Bedrock layer
    var _bedrock_depth = _world_height - _y;
    if (_bedrock_depth <= _world_data.get_bedrock_depth())
    {
        if (_bedrock_depth <= 1) return "phantasia:bedrock";
        var _bedrock_noise = open_simplex_noise(_x * _world_data.get_bedrock_noise_scale(), _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4) return "phantasia:bedrock";
    }
    
    var _overhang_threshold_tile = _world_data.get_cave_overhang_threshold_tile();
    var _is_overhang_solid = false;
    
    if (_overhang_threshold_tile != undefined)
    {
        var _overhang_noise_scale = _world_data.get_cave_overhang_noise_scale();
        var _overhang_noise = open_simplex_noise(_x * _overhang_noise_scale, _y * _overhang_noise_scale + (_seed * 293), 1.0, 2);
        
        if (_overhang_noise < _overhang_threshold_tile)
        {
             return TILE_EMPTY; // Void carve
        }
        else
        {
             if (_y < _surface_height) _is_overhang_solid = true;
        }
    }
    
    if (_y < _surface_height && !_is_overhang_solid) return TILE_EMPTY;
    
    // Generate context for MaterialProvider
    // Used for evaluating rules and noise-based placement
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 100), 1.0, 2);
    
    var _context = {
        x: _x,
        y: _y,
        surface_height: _surface_height,
        noise: _noise,
        cave_above: _cave_above,
        air_above: (_cave_above ? 1 : 0),
        cave_biome: _cave_biome
        // Add more context properties here as needed by rules
    }
    
    var _biome_data = global.biome_data;
    
    // Cave biome tiles (no horizontal blending for underground)
    if (_cave_biome != undefined)
    {
        var _biome = _biome_data[$ _cave_biome] ?? _biome_data[$ "phantasia:surface/forest"];
        if (_biome != undefined)
        {
            return _biome.get_tile_middle_layer().get_tile(_context);
        }
    }
    
    // Surface biome evaluation
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
    
    var _biome_to_use_id = _surface_biome;
    
    if (_is_boundary)
    {
        var _blend_noise = open_simplex_noise(_x * _blend_noise_scale, _y * _blend_noise_scale + 1000, 1.0, 2);
        if (_blend_noise > 0.2)
        {
            var _surface_biome_map = _world_data.get_surface_biome_map();
            if (_blend_noise > 0.55 && (_heat_left != _heat || _humidity_left != _humidity))
            {
                _biome_to_use_id = _surface_biome_map[(_humidity_left << WORLDGEN_SIZE_HEAT_BIT) | _heat_left];
            }
            else if (_blend_noise > 0.2 && (_heat_right != _heat || _humidity_right != _humidity))
            {
                _biome_to_use_id = _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right];
            }
        }
    }
    
    var _biome = _biome_data[$ _biome_to_use_id] ?? _biome_data[$ "phantasia:surface/forest"];
    
    if (_biome != undefined)
    {
        if (_cave_above) // Top Layer (Surface)
        {
            return _biome.get_tile_top_layer().get_tile(_context);
        }
        else // Middle Layer (Underground/Fill)
        {
            return _biome.get_tile_middle_layer().get_tile(_context);
        }
    }
    
    return TILE_EMPTY;
}
