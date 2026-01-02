function worldgen_get_heat(_x, _y, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _octaves = _world_data.get_surface_biome_heat().octaves;
    var _noise = open_simplex_noise(_x * _world_data.get_surface_heat_noise_scale(), _world_data.get_surface_heat_offset(), _world_data.get_surface_heat_range(), _octaves);
    
    var _spline_x = _world_data.get_surface_heat_spline_x();
    var _spline_y = _world_data.get_surface_heat_spline_y();
    
    var _gradient = 0;
    
    if (_spline_x != undefined) _gradient += spline_evaluate(_spline_x, _x);
    if (_spline_y != undefined) _gradient += spline_evaluate(_spline_y, _y);
    
    // Scale gradient to match range (assuming 0-1 spline output needs scaling to range)
    // Actually, splines define the "base" value. Noise adds variation.
    // Let's assume splines output directly in the target range or normalized.
    // The user request implies "stay in an area", so splines essentially set the "bias".
    
    // If we assume spline output is -1 to 1 (normalized like noise), we can map it.
    // Or if spline output is 0-255?
    // Looking at worlds.ts, I set the spline to -1 to 1.
    // Noise range is typically around 63 here.
    // So let's multiply gradient by range.
    
    var _range = _world_data.get_surface_heat_range();
    
    return clamp(round(_noise + (_gradient * _range)), 0, _range);
}