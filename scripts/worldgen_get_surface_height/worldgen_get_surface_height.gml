/// @desc Get surface height at world x position (uniform across all biomes)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _base_amplitude = _world_data.get_surface_noise_offset_max() - _world_data.get_surface_noise_offset_min();
    var _octaves = _world_data.get_surface_noise_offset_octaves();
    var _surface_start = _world_data.get_surface_start();
    
    // Calculate base terrain height for this position (uniform across all biomes)
    var _base_noise = open_simplex_noise(_x * _world_data.get_surface_noise_scale(), _world_data.get_surface_seed_offset(), _base_amplitude, _octaves);
    var _height = _surface_start - _world_data.get_surface_noise_offset_min() + round(_base_noise);
    
    return _height;
}