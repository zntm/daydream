function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed)
{
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    if (_cave_biome != undefined)
    {
        return global.biome_data[$ _cave_biome].get_tile_base();
    }
    
    if (_cave_above)
    {
        return global.biome_data[$ _surface_biome].get_tile_top_layer_base();
    }
    
    return global.biome_data[$ _surface_biome].get_tile_middle_layer_base();
}