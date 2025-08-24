function worldgen_get_cave_start(_x, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _amplitude = _world_data.get_cave_start_amplitude();
    var _octaves = _world_data.get_cave_start_octaves();
    
    return open_simplex_noise(_x / 64, 0xffff, _amplitude, _octaves);
}