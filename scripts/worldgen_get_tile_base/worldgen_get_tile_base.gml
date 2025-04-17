function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed)
{
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    if (_cave_biome != undefined)
    {
        return global.biome_data[$ _cave_biome].get_tile_base().id;
    }
    
    if (_y == _surface_height)
    {
        return global.biome_data[$ _surface_biome].get_tile_top_layer_base().id;
    }
    
    return global.biome_data[$ _surface_biome].get_tile_sub_layer_base().id;
}