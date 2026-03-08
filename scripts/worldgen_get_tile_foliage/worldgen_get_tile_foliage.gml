function worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _top_tile, _surface_height, _seed, _biome_data = undefined)
{
    var _biome_id = _cave_biome;
    
    // Fallback to surface biome ONLY if we are above the surface height (i.e. not underground)
    if (_biome_id == undefined)
    {
        if (_y <= _surface_height)
        {
            _biome_id = _surface_biome;
        }
        else
        {
            // Underground but no cave biome? Don't generate anything (prevents trees in caves)
            return TILE_EMPTY;
        }
    }

    _biome_data ??= global.biome_data;
    var _foliage = _biome_data[$ worldgen_resolve_id(_biome_id)];
    if (_foliage == undefined) return TILE_EMPTY;
    
    var _foliage_length = _foliage.get_tile_middle_layer_foliage_length();
    
    for (var i = 0; i < _foliage_length; ++i)
    {
        var _tile = _foliage.get_tile_middle_layer_foliage(i);
        
        if (chance_seeded(_tile.chance, _seed * ((_x ^ _y) + (i * 859))))
        {
            var _generate_on = _tile[$ "generate_on"];
            
            if (_generate_on == undefined) || (array_contains(_generate_on, _top_tile))
            {
                return _tile.id;
            }
        }
    }
    
    return TILE_EMPTY;
}