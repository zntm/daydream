function bg_get_biome(_x, _y, _surface_height = undefined)
{
    var _world_save_data = global.world_save_data;
    
    var _seed = _world_save_data.seed;
    
    _surface_height ??= worldgen_get_surface_height(_x, _seed);
     
    var _world_data = global.world_data[$ _world_save_data.dimension];
    

    
    // Check for cave biome (consistent with worldgen_get_biome_cave's 8-block buffer)
    if (_y > _surface_height + 8)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _seed);
        
        if (_cave_biome != undefined)
        {
            return _cave_biome;
        }
    }
    
    // Use heat/humidity for surface biome (Region system disabled/missing)
    var _biome_id = worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data);
    
    // Safety Fallback: Ensure the biome actually exists in the data
    if (global.biome_data[$ _biome_id] == undefined)
    {
        return "phantasia:surface/forest";
    }
    
    return _biome_id;
}