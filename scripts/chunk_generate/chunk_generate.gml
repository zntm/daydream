function chunk_generate()
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __surface_height = array_create(CHUNK_SIZE);
    
    var _surface_height_max = 0;
    
    static __structure_sort = function(_a, _b)
    {
        return ((_a.x * 0xffff) + _a.y) - ((_b.x * 0xffff) + _b.y);
    }
    
    static __structure_list_rectangle = ds_list_create();
    static __structure_list = ds_list_create();
    
    static __structure_array = [];
    
    var _item_data = global.item_data;
    
    var _natural_structure_data = global.natural_structure_data;
    var _structure_data = global.structure_data;
    
    var _world = global.world;
    
    var _world_data = global.world_data[$ _world.dimension];
    var _world_seed = _world.seed;
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = chunk_xstart + i;
        
        var _surface_height = worldgen_get_surface_height(_world_x, _world_seed);
        
        __surface_height[@ i] = _surface_height;
        
        _surface_height_max = min(_surface_height_max, _surface_height);
        
        var _cave_bit = 0;
        
        for (var j = 0; j < CHUNK_SIZE + 2; ++j)
        {
            var _world_y = chunk_ystart + j - 1;
            
            _cave_bit |= worldgen_get_cave(_world_x, _world_y, _surface_height, _world_seed) << j;
        }
        
        __cave_bit[@ i] = _cave_bit;
    }
    
    var _structure_rectangle_length = collision_rectangle_list(
        x - (TILE_SIZE / 2),
        y - (TILE_SIZE / 2),
        x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        obj_Structure,
        false,
        true,
        __structure_list_rectangle,
        false
    );
    
    if (_structure_rectangle_length <= 0) && (_surface_height_max > chunk_ystart + CHUNK_SIZE - 1) exit;
    
    for (var i = 0; i < _structure_rectangle_length; ++i)
    {
        structure_generate(__structure_list_rectangle[| i], _world_seed, _item_data, _structure_data, _natural_structure_data);
    }
    
    ds_list_clear(__structure_list_rectangle);
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = chunk_xstart + i;
        
        var _inst_x = _world_x * TILE_SIZE;
        
        var _surface_height = __surface_height[i];
        
        var _cave_bit = __cave_bit[i];
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = chunk_ystart + j;
            
            var _inst_y = _world_y * TILE_SIZE;
            
            var _skip_layer = 0;
            
            if (_structure_rectangle_length > 0) && (position_meeting(_inst_x, _inst_y, obj_Structure))
            {
                var _structure_length = instance_position_list(_inst_x, _inst_y, obj_Structure, __structure_list, false);
                
                for (var l = 0; l < _structure_length; ++l)
                {
                    __structure_array[@ l] = __structure_list[| l];
                }
                
                ds_list_clear(__structure_list);
                
                array_resize(__structure_array, _structure_length);
                
                array_sort(__structure_array, __structure_sort);
                
                for (var l = 0; l < _structure_length; ++l)
                {
                    var _inst = __structure_array[l];
                    
                    var _xscale = _inst.image_xscale;
                    var _yscale = _inst.image_yscale;
                    
                    var _rectangle = _xscale * _yscale;
                    
                    var _structure_x = _world_x - _inst.structure_xrelative;
                    var _structure_y = _world_y - _inst.structure_yrelative;
                    
                    var _structure_id = _inst.structure_id;
                    var _data = _inst.data;
                    
                    var _structure_index_xy = _structure_x + (_structure_y * _xscale);
                    
                    for (var m = CHUNK_DEPTH - 1; m >= 0; --m)
                    {
                        var _tile = _data[_structure_index_xy + (m * _rectangle)];
                        
                        if (_tile == TILE_STRUCTURE_VOID) continue;
                        
                        _skip_layer |= 1 << m;
                        
                        chunk[@ (m << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = _tile;
                        
                        if (_tile != TILE_EMPTY)
                        {
                            ++chunk_count[@ m];
                            
                            chunk_display |= 1 << m;
                        }
                    }
                    
                    if (++_inst.count >= _rectangle)
                    {
                        instance_destroy(_inst);
                    }
                }
            }
            
            if (_world_y >= _surface_height)
            {
                var _surface_biome = worldgen_get_biome_surface(_world_x, _world_y, _surface_height, _world_seed);
                var _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed);
                
                if ((_skip_layer & (1 << CHUNK_DEPTH_DEFAULT)) == 0) && ((_cave_bit & (1 << (j + 1))) == 0)
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _cave_bit & (1 << j), _world_seed);
                    
                    if (_tile_base != TILE_EMPTY)
                    {
                        ++chunk_count[@ CHUNK_DEPTH_DEFAULT];
                        
                        chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_base.id)
                            .set_index(smart_value(_item_data[$ _tile_base.id].get_placement_index()))
                            .set_index_offset(smart_value(_item_data[$ _tile_base.id].get_placement_index_offset()));
                        
                        chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                    }
                }
                
                var _tile_wall = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _world_seed);
                
                if ((_skip_layer & (1 << CHUNK_DEPTH_WALL)) == 0) && (_tile_wall != TILE_EMPTY)
                {
                    ++chunk_count[@ CHUNK_DEPTH_WALL];
                    
                    chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_wall.id)
                        .set_index(smart_value(_item_data[$ _tile_wall.id].get_placement_index()))
                        .set_index_offset(smart_value(_item_data[$ _tile_wall.id].get_placement_index_offset()));
                    
                    chunk_display |= 1 << CHUNK_DEPTH_WALL;
                }
            }
            
            var _z = ((xorshift(_world_seed ^ (_world_x * (_world_y + _surface_height))) & 1) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
            
            if ((_skip_layer & (1 << _z)) == 0) && (_world_y >= _surface_height - 1)
            {
                var _surface_biome = worldgen_get_biome_surface(_world_x, _world_y + 1, _surface_height, _world_seed);
                var _cave_biome = worldgen_get_biome_cave(_world_x, _world_y + 1, _surface_height, _world_seed);
                
                if ((_world_y == _surface_height - 1) || (_cave_bit & (1 << (j + 1)))) && (((_cave_bit & (1 << (j + 2)))) == 0)
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome, _cave_biome, _surface_height, true, _world_seed);
                    
                    var _tile_foliage = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome, _cave_biome, _tile_base, _surface_height, _world_seed);
                    
                    if (_tile_foliage != TILE_EMPTY)
                    {
                        ++chunk_count[@ _z];
                        
                        chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_foliage.id)
                            .set_xscale((xorshift(_world_seed + _world_x - _world_y) & 1) ? -1 : 1)
                            .set_index(smart_value(_item_data[$ _tile_foliage.id].get_placement_index()))
                            .set_index_offset(smart_value(_item_data[$ _tile_foliage.id].get_placement_index_offset()));
                        
                        chunk_display |= 1 << _z;
                    }
                }
            }
        }
    }
}