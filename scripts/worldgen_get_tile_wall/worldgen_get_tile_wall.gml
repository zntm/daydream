function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed)
{
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    if (_cave_biome != undefined)
    {
        return global.biome_data[$ _cave_biome].get_tile_wall().id;
    }
    
    if (_y == _surface_height)
    {
        return global.biome_data[$ _surface_biome].get_tile_top_layer_wall().id;
    }
    
    if (_y <= _surface_height + worldgen_get_surface_offset(_x, _seed))
    {
        return global.biome_data[$ _surface_biome].get_tile_sub_layer_wall().id;
    }
    
    return global.biome_data[$ _surface_biome].get_tile_bottom_layer_wall().id;
}