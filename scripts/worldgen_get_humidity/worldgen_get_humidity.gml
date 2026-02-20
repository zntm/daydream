/// @desc Samples the humidity map at the given position.
/// @returns {Real} Humidity value (-1 to 1)
function worldgen_get_humidity(_x, _y, _seed, _world_data = global.world_data[$ global.current_world.dimension])
{
	if (_world_data == undefined) return 0;
	
	return open_simplex_noise(
		_x * _world_data.get_surface_humidity_noise_scale(),
		_seed * 0.2 + 1000, // Different seed offset for humidity
		1.0,
		_world_data.get_surface_humidity_noise_octaves()
	);
}