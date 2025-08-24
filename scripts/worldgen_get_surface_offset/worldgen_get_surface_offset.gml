function worldgen_get_surface_offset(_x, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _amplitude = _world_data.get_surface_biome_offset_max() - _world_data.get_surface_offset_min();
    var _octaves = _world_data.get_surface_biome_offset_octaves();
    
    return _world_data.get_surface_offset_min() + round(open_simplex_noise(_x / 64, 0xffff + 48, _amplitude, _octaves));
}