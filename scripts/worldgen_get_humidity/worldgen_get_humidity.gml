function worldgen_get_humidity(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _octaves = _world_data.get_surface_biome_humidity().octaves;
    
    return round(open_simplex_noise(_x * _world_data.get_surface_humidity_noise_scale(), _world_data.get_surface_humidity_offset(), _world_data.get_surface_humidity_range(), _octaves));
}