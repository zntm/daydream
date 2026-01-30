function worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _heat = worldgen_get_heat(_x, _y, _seed, _world_data), _humidity = worldgen_get_humidity(_x, _y, _seed, _world_data))
{
    var _surface_biome_map = _world_data.get_surface_biome_map();
    if (_surface_biome_map == undefined) return "phantasia:surface/forest";
    
    _y = max(_y, _surface_height);
    
    var _index = (_humidity << WORLDGEN_SIZE_HEAT_BIT) | (_heat);
    
    return _surface_biome_map[_index] ?? "phantasia:surface/forest";
}