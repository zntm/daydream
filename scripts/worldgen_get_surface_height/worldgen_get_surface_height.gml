/// @desc Get surface height at world x position (biome-dependent)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    // Resolve Height via functional worldgen
    return worldgen_get_surface_height_3d(_x, _seed);
}