function worldgen_get_cave_start(_x, _seed, _world_data = global.world_data[$ global.current_world.dimension])
{
    var _amplitude = _world_data.get_cave_start_max() - _world_data.get_cave_start_min();
    var _octaves = _world_data.get_cave_start_octaves();
    
    return open_simplex_noise(_x * _world_data.get_cave_start_noise_scale(), _world_data.get_cave_start_offset(), _amplitude, _octaves);
}