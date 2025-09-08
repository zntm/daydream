function worldgen_get_humidity(_x, _y, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _octaves = _world_data.get_surface_biome_humidity_octaves();
    
    return round(open_simplex_noise(_x / 64, -24, 63, _octaves));
}