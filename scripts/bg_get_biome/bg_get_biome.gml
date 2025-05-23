function bg_get_biome(_x, _y)
{
    var _world = global.world;
    
    var _seed = _world.seed;
     
    var _world_data = global.world_data[$ _world.dimension];
    
    var _x2 = round(_x / TILE_SIZE);
    var _y2 = clamp(round(_y / TILE_SIZE), 0, _world_data.get_world_height() - 1);
    
    var _surface_height = worldgen_get_surface_height(_x2, _seed);
    
    if (_y2 > _surface_height + worldgen_get_cave_start(_x2, _seed))
    {
        var _cave_biome = worldgen_get_biome_cave(_x2, _y2, _surface_height, _seed);
        
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
    return worldgen_get_biome_surface(_x2, _y2, _surface_height, _seed);
}