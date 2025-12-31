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
    
    // Bedrock layer: bottom 3 tiles with randomized edges
    // Layer 0-1: always bedrock, Layer 2: noise-based edge
    var _bedrock_depth = _world_height - _y;
    if (_bedrock_depth <= 3)
    {
        if (_bedrock_depth <= 1)
        {
            return "phantasia:bedrock";
        }
        // Use noise for ragged bedrock edge
        var _bedrock_noise = open_simplex_noise(_x * 0.3, _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4)
        {
            return "phantasia:bedrock";
        }
    }
    
    // Note: Lava ocean is handled by worldgen_get_cave - empty caves in deep areas fill with lava
    
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    // Generate noise value (0..1) for coherent tile variation
    // Scale 0.05 gives medium-sized patches (~20 blocks)
    var _noise = open_simplex_noise(_x * 0.05, _y * 0.05 + (_seed * 100), 1.0, 2);
    
    // Horizontal tile blending at biome edges - larger range for big biomes
    static __BLEND_RANGE = 24;         // Tiles to sample for edge detection
    static __BLEND_NOISE_SCALE = 0.08; // Noise scale for blend variation
    
    // Cave biome tiles (no horizontal blending for underground)
    if (_cave_biome != undefined)
    {
        return global.biome_data[$ _cave_biome].get_tile_middle_layer_base(_noise);
    }
    
    // Fallback if underground but no cave biome found
    // Respect the 8-block surface buffer - only force cave biome if deeper
    if (_y > _surface_height + 8)
    {
        var _default_caves = global.world_data[$ global.world_save_data.dimension].get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome = _default_caves[array_length(_default_caves) - 1].id; 
            return global.biome_data[$ _def_biome].get_tile_middle_layer_base(_noise);
        }
    }
    
    // Surface biome tiles with horizontal blending
    
    // Check if we're near a biome boundary for horizontal tile blending
    var _heat = worldgen_get_heat(_x, 0, _seed, _world_data);
    var _humidity = worldgen_get_humidity(_x, 0, _seed, _world_data);
    var _heat_left = worldgen_get_heat(_x - __BLEND_RANGE, 0, _seed, _world_data);
    var _heat_right = worldgen_get_heat(_x + __BLEND_RANGE, 0, _seed, _world_data);
    var _humidity_left = worldgen_get_humidity(_x - __BLEND_RANGE, 0, _seed, _world_data);
    var _humidity_right = worldgen_get_humidity(_x + __BLEND_RANGE, 0, _seed, _world_data);
    
    var _is_boundary = (_heat != _heat_left) || (_heat != _heat_right) || 
                       (_humidity != _humidity_left) || (_humidity != _humidity_right);
    
    var _biome_to_use = _surface_biome;
    
    if (_is_boundary)
    {
        // Generate blend noise to decide which biome's tile to use at this edge position
        var _blend_noise = open_simplex_noise(_x * __BLEND_NOISE_SCALE, _y * __BLEND_NOISE_SCALE + 1000, 1.0, 2);
        
        // Blend probability based on proximity to boundary (noise controls randomness)
        if (_blend_noise > 0.2)
        {
            var _surface_biome_map = _world_data.get_surface_biome_map();
            
            // Pick a neighboring biome based on noise value
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
    
    if (_cave_above)
    {
        return global.biome_data[$ _biome_to_use].get_tile_top_layer_base(_noise);
    }
    
    return global.biome_data[$ _biome_to_use].get_tile_middle_layer_base(_noise);
}