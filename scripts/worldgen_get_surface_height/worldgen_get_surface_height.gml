/// @desc Get surface height at world x position (biome-dependent)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    // Resolve Region (using RegionGenerator)
    var _region = global.region_generator.get_region(_x, 0, 0, _seed);
    
    // Resolve Height via TerrainGenerator (Density-based)
    return global.terrain_generator.get_surface_height(_x, _region, _seed);
}