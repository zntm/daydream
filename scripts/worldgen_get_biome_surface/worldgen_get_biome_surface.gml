function worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.world_save_data.dimension], _heat = undefined, _humidity = undefined)
{
    var _surface_biome_map = _world_data.get_surface_biome_map();
    
    _y = max(_y, _surface_height + 8);
    
    if (_heat == undefined) _heat = worldgen_get_heat(_x, _y, _seed, _world_data);
    if (_humidity == undefined) _humidity = worldgen_get_humidity(_x, _y, _seed, _world_data);
    
    return _surface_biome_map[
        (_humidity << WORLDGEN_SIZE_HEAT_BIT) |
        (_heat)
    ];
}