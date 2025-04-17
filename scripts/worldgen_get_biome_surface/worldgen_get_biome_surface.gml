function worldgen_get_biome_surface(_x, _y, _surface_height, _seed)
{
    return global.world_data[$ global.world.dimension].get_surface_biome_map()[
        (worldgen_get_humidity(_x, _y, _seed) << WORLDGEN_SIZE_HEAT_BIT)
        (worldgen_get_heat(_x, _y, _seed))
    ];
}