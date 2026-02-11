/// @desc DEPRECATED: Biome selection no longer uses heat/humidity maps.
/// @returns {Real} 0
function worldgen_get_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
	return 0;
}