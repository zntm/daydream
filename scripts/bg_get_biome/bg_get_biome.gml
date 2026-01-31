function bg_get_biome(_x, _y, _surface_height = undefined)
{
    var _world_save_data = global.world_save_data;
    
    var _seed = _world_save_data.seed;
    
    _surface_height ??= worldgen_get_surface_height(_x, _seed);
     
    var _world_data = global.world_data[$ _world_save_data.dimension];
    /*
    // Check for sky biome first (highest priority)
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    
    if (_y <= _sky_threshold && _world_data.is_sky_biome_enabled())
    {
        if (worldgen_get_sky_island(_x, _y, _seed, _world_data))
        {
            return _world_data.get_sky_biome_id();
        }
    }
    */
    // Check for cave biome (consistent with worldgen_get_biome_cave's 8-block buffer)
    if (_y > _surface_height + 8)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _seed);
        
        if (_cave_biome != undefined)
        {
            return _cave_biome;
        }
    }
    
    return worldgen_get_biome_surface(_x, _y, _surface_height, _seed);
}