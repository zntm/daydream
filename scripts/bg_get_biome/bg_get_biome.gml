function bg_get_biome(_x, _y, _surface_height = undefined, _slope = undefined)
{
    var _world_save_data = global.world_save_data;
    var _seed = _world_save_data.seed;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    _surface_height ??= worldgen_get_surface_height(_x, _seed, _world_data);
    
    // Calculate slope if not provided
    if (_slope == undefined)
    {
        var _h_left = worldgen_get_surface_height(_x - 1, _seed, _world_data);
        var _h_right = worldgen_get_surface_height(_x + 1, _seed, _world_data);
        _slope = max(abs(_surface_height - _h_left), abs(_h_right - _surface_height));
    }
     
    // Check for cave biome
    if (_y > _surface_height + 8)
    {
        return worldgen_get_biome_cave(_x, _y, _surface_height, _seed, _world_data);
    }
    
    return worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data, _slope);
}