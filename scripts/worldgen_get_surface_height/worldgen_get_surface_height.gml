function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    return round(worldgen_get_surface_height_at(_x, _seed));
}