function worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _top_tile, _surface_height, _seed)
{
    var _foliage = global.biome_data[$ _cave_biome ?? _surface_biome];
    
    if (chance_seeded(_foliage.get_tile_foliage_chance(), _seed - _x))
    {
        var _tile = choose_weighted(_foliage.get_tile_foliage_tile());
        
        if (array_contains(_tile.placeable_on, _top_tile.id))
        {
            return _tile;
        }
    }
    
    return TILE_EMPTY;
}