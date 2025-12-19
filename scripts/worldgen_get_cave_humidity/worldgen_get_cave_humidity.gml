function worldgen_get_cave_humidity(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _humidity = _world_data.get_cave_biome_humidity();
    if (_humidity == undefined) return 0;
    
    var _octaves = _humidity.octaves;
    
    return round(open_simplex_noise(_x * 0.015625, -16, 63, _octaves + 16));
}
