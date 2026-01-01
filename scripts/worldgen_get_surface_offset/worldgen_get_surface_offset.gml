function worldgen_get_surface_noise_offset(_x, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _amplitude = _world_data.get_surface_noise_offset_max() - _world_data.get_surface_noise_offset_min();
    var _octaves = _world_data.get_surface_noise_offset_octaves();
    
    return _world_data.get_surface_noise_offset_min() + abs(round(open_simplex_noise(_x * _world_data.get_surface_noise_offset_scale(), _world_data.get_surface_noise_offset_y(), _amplitude, _octaves)));
}