// DEPRECATED: Use worldgen_is_solid instead
function worldgen_get_cave(_x, _y, _surface_height, _cave_start, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    return !worldgen_is_solid(_x, _y, _seed);
}
