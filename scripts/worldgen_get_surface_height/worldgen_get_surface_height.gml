/// @desc Get surface height at world x position (uniform across all biomes)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    // 1. Find region at this position
    var _region = global.region_generator.get_region(_x, 0, 0, _seed);
    var _terrain = _region.get_terrain();
    
    // 2. Resolve surface biome at this position (for subtle modifiers)
    var _biome = _region.get_surface_biome(_x, 0, _seed);
    
    var _biome_offset = 0;
    var _biome_amp_scale = 1;
    
    if (_biome != undefined)
    {
        _biome_offset = _biome.get_terrain_height_offset();
        _biome_amp_scale = _biome.get_terrain_amplitude_scale();
    }
    else
    {
        show_debug_message($"[WorldGen] Warning: Surface biome undefined at x={_x}. Using defaults.");
    }
    
    // 3. Extract terrain parameters
    var _base_height = _terrain.base_height + _terrain.height_offset + _biome_offset;
    var _amplitude_min = _terrain.amplitude_min;
    var _amplitude_max = _terrain.amplitude_max;
    var _noise_scale = _terrain.noise_scale;
    var _gradient_strength = _terrain.gradient_strength;
    
    // 4. Calculate terrain noise
    // Using simple voronoi-influenced simplex noise for height
    var _noise = open_simplex_noise(_x * _noise_scale, _seed * 0.1, 1.0, 3);
    var _noise_norm = (_noise + 1) * 0.5;
    
    // Amplitude varies with noise
    var _amplitude = lerp(_amplitude_min, _amplitude_max, _noise_norm) * _biome_amp_scale;
    
    // Final height calculation
    var _height = _base_height + round(_noise * _amplitude);
    
    return _height;
}