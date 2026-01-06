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
    
    // Check for sky biome tiles first
    var _sky_biome_threshold = _world_data.get_sky_biome_threshold();
    
    if (_y <= _sky_biome_threshold && _world_data.is_sky_biome_enabled())
    {
        var _is_sky_biome = worldgen_get_sky_island(_x, _y, _world_seed, _world_data);
        
        if (_is_sky_biome)
        {
            var _sky_biome_data = global.biome_data[$ _world_data.get_sky_biome_id()];
            
            if (_sky_biome_data != undefined)
            {
                if (_z == CHUNK_DEPTH_DEFAULT)
                {
                    var _is_above_sky = worldgen_get_sky_island(_x, _y - 1, _world_seed, _world_data);
                    var _is_below_sky = worldgen_get_sky_island(_x, _y + 1, _world_seed, _world_data);
                    
                    var _tile_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _world_seed;
                    var _tile_id;
                    
                    if (!_is_above_sky)
                    {
                        // Top of sky biome - grass
                        _tile_id = _sky_biome_data.get_tile_top_layer_base(_tile_seed);
                    }
                    else if (!_is_below_sky)
                    {
                        // Bottom of sky biome - stone
                        _tile_id = _sky_biome_data.get_tile_bottom_layer_base(_tile_seed);
                    }
                    else
                    {
                        // Middle of sky biome - dirt
                        _tile_id = _sky_biome_data.get_tile_middle_layer_base(_tile_seed);
                    }
                    
                    if (_tile_id != TILE_EMPTY)
                    {
                        var _data = global.item_data[$ _tile_id];
                        
                        if (_data != undefined)
                        {
                            return new Tile(_tile_id)
                                .set_index(smart_value(_data.get_placement_index()))
                                .set_index_offset(smart_value(_data.get_placement_index_offset()));
                        }
                    }
                }
                
                if (_z == CHUNK_DEPTH_WALL)
                {
                    var _tile_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _world_seed;
                    var _tile_wall = _sky_biome_data.get_tile_middle_layer_wall(_tile_seed);
                    
                    if (_tile_wall != TILE_EMPTY)
                    {
                        return new Tile(_tile_wall);
                    }
                }
                
                return TILE_EMPTY;
            }
        }
    }
    
    var _surface_height = worldgen_get_surface_height(_x, _world_seed);
    
    if (_y >= _surface_height)
    {
        var _surface_biome = worldgen_get_biome_surface(_x, _y, _surface_height, _world_seed);
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed);
        
        if (_z == CHUNK_DEPTH_DEFAULT)
        {
            var _cave_start = worldgen_get_cave_start(_x, _world_seed);
            
            if (!worldgen_get_cave(_x, _y, _surface_height, _cave_start, _world_seed))
            {
                var _tile_base = worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, worldgen_get_cave(_x, _y - 1, _surface_height, _cave_start, _world_seed), _world_seed);
                
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
        var _cave_start = worldgen_get_cave_start(_x, _world_seed);
        
        if (worldgen_get_cave(_x, _y, _surface_height, _cave_start, _world_seed)) && (!worldgen_get_cave(_x, _y + 1, _surface_height, _cave_start, _world_seed))
        {
            var _surface_biome = worldgen_get_biome_surface(_x, _y + 1, _surface_height, _world_seed);
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