function worldgen_get_cave_start(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _amplitude = _world_data.get_cave_start_max() - _world_data.get_cave_start_min();
    var _octaves = _world_data.get_cave_start_octaves();
    
    return open_simplex_noise(_x * 0.015625, -8, _amplitude, _octaves);
}