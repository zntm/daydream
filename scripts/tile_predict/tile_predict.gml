function tile_predict(_x, _y, _z)
{
    var _world_seed = global.world_save_data.seed;
    
    var _inst = instance_position(_x * TILE_SIZE, _y * TILE_SIZE, obj_Structure);
    
    if (instance_exists(_inst))
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
        var _surface_biome = worldgen_get_biome_surface(_x, _y, _surface_height, _world_seed);
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed);
        
        if (_z == CHUNK_DEPTH_DEFAULT)
        {
            if (!worldgen_get_cave(_x, _y, _surface_height, _world_seed))
            {
                var _tile_base = worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, worldgen_get_cave(_x, _y - 1, _surface_height, _world_seed), _world_seed);
                
                if (_tile_base != TILE_EMPTY)
                {
                    return new Tile(_tile_base.id);
                }
            }
        }
        
        if (_z == CHUNK_DEPTH_WALL)
        {
            var _tile_wall = worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _world_seed);
            
            if (_tile_wall != TILE_EMPTY)
            {
                return new Tile(_tile_wall.id);
            }
        }
        
        return TILE_EMPTY;
    }
    
    var _z2 = ((xorshift(_world_seed ^ (_x * (_y + _surface_height))) & 1) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
    
    if (_z == _z2) && (_y >= _surface_height - 1)
    {
        if (worldgen_get_cave(_x, _y, _surface_height, _world_seed)) && (!worldgen_get_cave(_x, _y + 1, _surface_height, _world_seed))
        {
            var _surface_biome = worldgen_get_biome_surface(_x, _y + 1, _surface_height, _world_seed);
            var _cave_biome = worldgen_get_biome_cave(_x, _y + 1, _surface_height, _world_seed);
            
            var _tile_base = worldgen_get_tile_base(_x, _y + 1, _surface_biome, _cave_biome, _surface_height, true, _world_seed);
            
            var _tile_foliage = worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _tile_base, _surface_height, _world_seed);
            
            if (_tile_foliage != TILE_EMPTY)
            {
                return new Tile(_tile_foliage.id)
                    .set_xscale((xorshift(_world_seed + _x - _y) & 1) ? -1 : 1);
            }
        }
    }
    
    return TILE_EMPTY;
}