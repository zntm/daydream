function worldgen_get_biome_surface(_x, _y, _surface_height, _seed)
{
    var _surface_biome_map = global.world_data[$ global.world_save_data.dimension].get_surface_biome_map();
    
    _y = max(_y, _surface_height + 8);
    
    show_debug_message($"{_x} {_y} {worldgen_get_humidity(_x, _y, _seed)} {worldgen_get_heat(_x, _y, _seed)} {_surface_biome_map[
        (worldgen_get_humidity(_x, _y, _seed) << WORLDGEN_SIZE_HEAT_BIT) |
        (worldgen_get_heat(_x, _y, _seed))
    ]}")
    
    return _surface_biome_map[
        (worldgen_get_humidity(_x, _y, _seed) << WORLDGEN_SIZE_HEAT_BIT) |
        (worldgen_get_heat(_x, _y, _seed))
    ];
}