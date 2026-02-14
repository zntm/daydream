function worldgen_get_humidity(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _octaves = _world_data.get_surface_biome_humidity().octaves;
    var _noise = open_simplex_noise(_x * _world_data.get_surface_humidity_noise_scale(), _world_data.get_surface_humidity_offset(), _world_data.get_surface_humidity_range(), _octaves);
    
    var _spline_x = _world_data.get_surface_humidity_spline_x();
    var _spline_y = _world_data.get_surface_humidity_spline_y();
    
    var _gradient = 0;
    
    if (_spline_x != undefined) _gradient += spline_evaluate(_spline_x, _x);
    if (_spline_y != undefined) _gradient += spline_evaluate(_spline_y, _y);
    
    var _range = _world_data.get_surface_humidity_range();
    
    return clamp(round(_noise + (_gradient * _range)), 0, _range);
}