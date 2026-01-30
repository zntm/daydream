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
    
    // Use Region system for surface biome (consistent with chunk_generate)
    var _region = global.region_generator.get_region(_x, 0, 0, _seed);
    var _biome_id = _region.get_surface_biome_id();
    
    // Safety Fallback: Ensure the biome actually exists in the data
    if (global.biome_data[$ _biome_id] == undefined)
    {
        return "phantasia:surface/forest";
    }
    
    return _biome_id;
}