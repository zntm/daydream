#macro WORLDGEN_HUMIDITY_NOISE_SIZE 128

function worldgen_get_humidity(_x, _y, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _octaves = _world_data.get_surface_biome_humidity_octaves();
    
    return round(open_simplex_noise_3d(_x / 64, 0, 24, WORLDGEN_SIZE_HUMIDITY, _octaves));
}