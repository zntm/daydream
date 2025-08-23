function worldgen_get_surface_height(_x, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _amplitude = _world_data.get_surface_offset_max();
    var _octaves = _world_data.get_surface_offset_octaves();
    
    return _world_data.get_surface_start() + _world_data.get_surface_offset_min() - round(open_simplex_noise_3d(_x / 64, 0, 16, _amplitude, _octaves));
}