function worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _top_tile, _surface_height, _seed)
{
    var _foliage = global.biome_data[$ _cave_biome ?? _surface_biome];
    var _foliage_length = _foliage.get_tile_foliage_length();
    
    for (var i = 0; i < _foliage_length; ++i)
    {
        var _tile = _foliage.get_tile_foliage(i);
        
        if (chance_seeded(_tile.chance, _seed * ((_x ^ _y) + (i * 859))) && (array_contains(_tile.placeable_on, _top_tile.id)))
        {
            return _tile;
        }
    }
    
    return TILE_EMPTY;
}