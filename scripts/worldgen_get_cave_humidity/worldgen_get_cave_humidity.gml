function worldgen_get_cave_humidity(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _humidity = _world_data.get_cave_biome_humidity();
    if (_humidity == undefined) return 0;
    
    var _octaves = _humidity.octaves;
    
    return round(open_simplex_noise(_x * _world_data.get_cave_humidity_noise_scale_x(), _y * _world_data.get_cave_humidity_noise_scale_y() + _world_data.get_cave_humidity_offset_y(), _world_data.get_cave_humidity_range(), _octaves + _world_data.get_cave_humidity_octaves_offset()));
}
