function worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _top_tile, _surface_height, _seed)
{
    var _biome_id = _cave_biome;
    if (_biome_id == undefined) _biome_id = _surface_biome;
    
    if (_biome_id == undefined) return TILE_EMPTY;

    var _foliage = global.biome_data[$ _biome_id];
    
    // Safety check
    if (_foliage == undefined) return TILE_EMPTY;
    
    // Check for MaterialProvider-based foliage
    var _provider = _foliage.get_tile_foliage();
    
    if (_provider != undefined)
    {
        var _noise = open_simplex_noise(_x * 0.1, _y * 0.1 + (_seed * 200), 1.0, 1);
        var _context = {
            x: _x, y: _y, surface_height: _surface_height, noise: _noise, top_tile: _top_tile,
            cave_above: true,
            air_above: 1,
            cave_biome: _cave_biome
        }
        return _provider.get_tile(_context);
    }

    return TILE_EMPTY;
}
