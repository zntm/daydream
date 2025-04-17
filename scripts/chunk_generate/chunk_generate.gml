function chunk_generate()
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __surface_height = array_create(CHUNK_SIZE);
    
    var _world_xstart = floor(x / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE;
    var _world_ystart = floor(y / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE;
    
    var _world = global.world;
    
    var _world_data = global.world_data[$ _world.dimension];
    var _world_seed = _world.seed;
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _world_xstart + i;
        
        var _surface_height = worldgen_get_surface_height(_world_x, _world_seed);
        
        __surface_height[@ i] = _surface_height;
        
        var _cave_bit = 0;
        
        for (var j = 0; j < CHUNK_SIZE + 1; ++j)
        {
            var _world_y = _world_ystart + j;
            
            _cave_bit |= worldgen_get_cave(_world_x, _world_y, _surface_height, _world_seed) << j;
        }
        
        __cave_bit[@ i] = _cave_bit;
    }
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _world_xstart + i;
        
        var _surface_height = __surface_height[i];
        
        var _cave_bit = __cave_bit[i];
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _world_ystart + j;
            
            var _surface_biome = worldgen_get_biome_surface(_world_x, _world_y, _surface_height, _world_seed);
            var _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed);
            
            if (_world_y >= _surface_height)
            {
                if ((_cave_bit & (1 << j)) == 0)
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _world_seed);
                    
                    if (_tile_base != TILE_EMPTY)
                    {
                        chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_base);
                        
                        chunk_surface_display |= 1 << CHUNK_DEPTH_DEFAULT;
                    }
                }
                
                var _tile_wall = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _world_seed);
                
                if (_tile_wall != TILE_EMPTY)
                {
                    chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_wall);
                    
                    chunk_surface_display |= 1 << CHUNK_DEPTH_WALL;
                }
            }
            
            if (_world_y >= _surface_height - 1)
            {
                if (_world_y == _surface_height - 1) || ((_cave_bit & (1 << j)) && ((_cave_bit & (1 << (j + 1)))) == 0)
                {
                    var _tile_foliage = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome, _cave_biome, worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome, _cave_biome, _surface_height, _world_seed), _surface_height, _world_seed);
                    
                    if (_tile_foliage != TILE_EMPTY)
                    {
                        var _z = (chance_seeded(0.5, _world_seed + _world_x + _world_y) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
                        
                        chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_foliage)
                            .set_xscale(choose(-1, 1));
                        
                        chunk_surface_display |= 1 << _z;
                    }
                }
            }
        }
    }
}