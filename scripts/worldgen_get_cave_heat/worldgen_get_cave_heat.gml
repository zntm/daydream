function worldgen_get_cave_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _heat = _world_data.get_cave_biome_heat();
    if (_heat == undefined) return 0;
    
    var _octaves = _heat.octaves;
    
    return round(open_simplex_noise(_x * 0.015625, _y * 0.015625, 63, _octaves));
}
