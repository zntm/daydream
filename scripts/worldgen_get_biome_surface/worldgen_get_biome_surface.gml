function worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _heat = worldgen_get_heat(_x, _y, _seed, _world_data), _humidity = worldgen_get_humidity(_x, _y, _seed, _world_data))
{
    var _surface_biome_map = _world_data.get_surface_biome_map();
    
    _y = max(_y, _surface_height + _world_data.get_surface_min_depth());
    
    var _heat_range = _world_data.get_surface_heat_range();
    var _humidity_range = _world_data.get_surface_humidity_range();
    
    // Remap values to map size (e.g., 255 -> 63)
    // ensure divisor is not 0
    if (_heat_range == 0) _heat_range = 255;
    if (_humidity_range == 0) _humidity_range = 255;
    
    var _map_heat = round((_heat / _heat_range) * (WORLDGEN_SIZE_HEAT - 1));
    var _map_humidity = round((_humidity / _humidity_range) * (WORLDGEN_SIZE_HUMIDITY - 1));
    
    _map_heat = clamp(_map_heat, 0, WORLDGEN_SIZE_HEAT - 1);
    _map_humidity = clamp(_map_humidity, 0, WORLDGEN_SIZE_HUMIDITY - 1);
    
    return _surface_biome_map[
        (_map_humidity << WORLDGEN_SIZE_HEAT_BIT) |
        (_map_heat)
    ];
}