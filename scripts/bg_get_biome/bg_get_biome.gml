function bg_get_biome(_x, _y, _surface_height = undefined, _heat = undefined, _humidity = undefined)
{
    var _world_save_data = global.world_save_data;
    var _seed = _world_save_data.seed;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    _surface_height ??= worldgen_get_surface_height(_x, _seed, _world_data);
     
    // Check for cave biome (consistent with worldgen_get_biome_cave's 8-block buffer)
    if (_y > _surface_height + 8)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _seed, _world_data, _heat, _humidity);
        
        if (_cave_biome != undefined)
        {
            return _cave_biome;
        }
    }
    
    return worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data, _heat, _humidity);
}