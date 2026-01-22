function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _base_height = _world_data.get_surface_start();
    
    // Noise settings
    var _octaves = _world_data.get_surface_noise_offset_octaves();
    var _range_min = _world_data.get_surface_noise_offset_range_min();
    var _range_max = _world_data.get_surface_noise_offset_range_max();
    var _noise_scale = _world_data.get_surface_noise_scale();
    
    // Simple 1D noise for surface variation
    var _noise = open_simplex_noise(_x * _noise_scale, _seed * 100, 1.0, _octaves);
    
    // Map noise -1..1 to range_min..range_max (roughly)
    // Formula: base + lerp(min, max, (noise + 1) / 2)
    var _offset = lerp(_range_min, _range_max, (_noise + 1) / 2);
    
    return round(_base_height + _offset);
}