function worldgen_get_cave_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _heat = _world_data.get_cave_biome_heat();
    if (_heat == undefined) return 0;
    
    var _octaves = _heat.octaves;
    
    return round(open_simplex_noise(_x * _world_data.get_cave_heat_noise_scale_x(), _y * _world_data.get_cave_heat_noise_scale_y(), _world_data.get_cave_heat_range(), _octaves));
}
