/// @desc Get surface height at world x position (biome-dependent)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _surface_start = _world_data.get_surface_start();
    var _blend_range = _world_data.get_biome_blend_range();
    
    // Sample biomes at current position and neighbors for blending
    // Using 3-point weighted average for smooth transitions
    var _biome_c_id = worldgen_get_biome_surface(_x, 0, 0, _seed, _world_data);
    var _biome_l_id = worldgen_get_biome_surface(_x - _blend_range, 0, 0, _seed, _world_data);
    var _biome_r_id = worldgen_get_biome_surface(_x + _blend_range, 0, 0, _seed, _world_data);
    
    var _biome_c = global.biome_data[$ _biome_c_id] ?? global.biome_data[$ "phantasia:surface/forest"];
    var _biome_l = global.biome_data[$ _biome_l_id] ?? global.biome_data[$ "phantasia:surface/forest"];
    var _biome_r = global.biome_data[$ _biome_r_id] ?? global.biome_data[$ "phantasia:surface/forest"];
    
    // Safety check in case forest biome is also missing
    if (_biome_c == undefined) return _surface_start;
    if (_biome_l == undefined) _biome_l = _biome_c;
    if (_biome_r == undefined) _biome_r = _biome_c;
    
    // Weights: Center has 50%, Left/Right have 25% each
    // This ensures distinct biome features in the middle but smooths edges
    var _scale   = (_biome_c.get_terrain_noise_scale()   * 0.5) + (_biome_l.get_terrain_noise_scale()   * 0.25) + (_biome_r.get_terrain_noise_scale()   * 0.25);
    var _offset  = (_biome_c.get_terrain_height_offset() * 0.5) + (_biome_l.get_terrain_height_offset() * 0.25) + (_biome_r.get_terrain_height_offset() * 0.25);
    var _amp_min = (_biome_c.get_terrain_amplitude_min() * 0.5) + (_biome_l.get_terrain_amplitude_min() * 0.25) + (_biome_r.get_terrain_amplitude_min() * 0.25);
    var _amp_max = (_biome_c.get_terrain_amplitude_max() * 0.5) + (_biome_l.get_terrain_amplitude_max() * 0.25) + (_biome_r.get_terrain_amplitude_max() * 0.25);
    var _octaves = max(_biome_c.get_terrain_octaves(), _biome_l.get_terrain_octaves(), _biome_r.get_terrain_octaves()); // Pick max detail
    
    // Calculate noise amplitude
    var _amplitude = _amp_max - _amp_min;
    
    // Calculate terrain height using blended parameters
    // Note: Use a fixed large offset for Y in noise to differentiate from other noise maps
    var _noise = open_simplex_noise(_x * _scale, _seed + 12345, _amplitude, _octaves);
    
    // Result = SeaLevel + BaseOffset + Noise
    var _height = _surface_start + _offset + round(_noise);
    
    return _height;
}