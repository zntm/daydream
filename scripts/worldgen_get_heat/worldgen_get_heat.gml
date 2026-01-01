function worldgen_get_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _octaves = _world_data.get_surface_biome_heat().octaves;
    
    return round(open_simplex_noise(_x * _world_data.get_surface_heat_noise_scale(), _world_data.get_surface_heat_offset(), _world_data.get_surface_heat_range(), _octaves));
}