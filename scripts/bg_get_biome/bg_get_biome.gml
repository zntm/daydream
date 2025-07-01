function bg_get_biome(_x, _y)
{
    var _world_save_data = global.world_save_data;
    
    var _seed = _world_save_data.seed;
     
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _surface_height = worldgen_get_surface_height(_x, _seed);
    
    if (_y > _surface_height + worldgen_get_cave_start(_x, _seed))
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _seed);
        
        if (_cave_biome != undefined)
        {
            return _cave_biome;
        }
    }
    /*
    var _sky_biome = worldgen_get_biome_sky(_x2, _y2, _seed);
    
    if (_sky_biome != undefined)
    {
        return _sky_biome;
    }
    */
    return worldgen_get_biome_surface(_x, _y, _surface_height, _seed);
}