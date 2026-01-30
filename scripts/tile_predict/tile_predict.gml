function tile_predict(_x, _y, _z)
{
    var _world_seed = global.world_save_data.seed;
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _inst = global.structure_pool.query_position(_x * TILE_SIZE, _y * TILE_SIZE);
    
    if (_inst != noone)
    {
        var _xscale = _inst.image_xscale;
        var _yscale = _inst.image_yscale;
        
        var _structure_xrelative = _inst.structure_xrelative;
        var _structure_yrelative = _inst.structure_yrelative;
        
        var _data = structure_generate(_inst, _world_seed, global.item_data, global.structure_data, global.natural_structure_data);
        
        var _structure_x = _x - _structure_xrelative;
        var _structure_y = _y - _structure_yrelative;
        
        var _tile = _data[_structure_x + (_structure_y * _xscale) + (_z * _xscale * _yscale)];
        
        if (_tile != TILE_STRUCTURE_VOID)
        {
            return _tile;
        }
    }
    

    
    var _surface_height = worldgen_get_surface_height(_x, _world_seed);
    
    if (_y >= _surface_height)
    {
        var _region = global.region_generator.get_region(_x, 0, 0, _world_seed);
        var _surface_biome = _region.get_surface_biome_id();
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed);
        
        if (_z == CHUNK_DEPTH_DEFAULT)
        {
            var _is_cave = !worldgen_is_solid(_x, _y, _world_seed);
            var _is_cave_above = !worldgen_is_solid(_x, _y - 1, _world_seed);
            
            if (!_is_cave)
            {
                var _tile_base = worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _is_cave_above, _world_seed);
                
                if (_tile_base != TILE_EMPTY)
                {
                    return new Tile(_tile_base);
                }
            }
        }
        
        if (_z == CHUNK_DEPTH_WALL)
        {
            var _tile_wall = worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _world_seed);
            
            if (_tile_wall != TILE_EMPTY)
            {
                return new Tile(_tile_wall);
            }
        }
        
        return TILE_EMPTY;
    }
    
    var _z2 = ((xorshift(_world_seed ^ (_x * (_y + _surface_height))) & 1) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
    
    if (_z == _z2) && (_y >= _surface_height - 1)
    {
        var _is_cave = !worldgen_is_solid(_x, _y, _world_seed);
        var _is_cave_below = !worldgen_is_solid(_x, _y + 1, _world_seed);
        
        if (_is_cave && !_is_cave_below)
        {
            var _region2 = global.region_generator.get_region(_x, 0, 0, _world_seed);
            var _surface_biome = _region2.get_surface_biome_id();
            var _cave_biome = worldgen_get_biome_cave(_x, _y + 1, _surface_height, _world_seed);
            
            var _tile_base = worldgen_get_tile_base(_x, _y + 1, _surface_biome, _cave_biome, _surface_height, true, _world_seed);
            
            var _tile_foliage = worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _tile_base, _surface_height, _world_seed);
            
            if (_tile_foliage != TILE_EMPTY)
            {
                return new Tile(_tile_foliage)
                    .set_xscale((xorshift(_world_seed + _x - _y) & 1) ? -1 : 1);
            }
        }
    }
    
    return TILE_EMPTY;
}