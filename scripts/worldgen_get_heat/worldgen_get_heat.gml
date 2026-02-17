/// @desc Samples the heat map at the given position.
/// @returns {Real} Heat value (-1 to 1)
function worldgen_get_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
	if (_world_data == undefined) return 0;
	
	return open_simplex_noise(
		_x * _world_data.get_surface_heat_noise_scale(),
		_seed * 0.1, // Using seed with offset for heat coherence
		1.0,
		_world_data.get_surface_heat_noise_octaves()
	);
}