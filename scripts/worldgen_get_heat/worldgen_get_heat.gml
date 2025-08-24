function worldgen_get_heat(_x, _y, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _octaves = _world_data.get_surface_biome_heat_octaves();
    
    return round(open_simplex_noise(_x / 64, 0xffff + 16, 63, _octaves));
}