/// @function chunk_generate(_chunk)
/// @desc Generate terrain for a _chunk.chunk
/// @param {Struct.Chunk} _chunk The _chunk.chunk to generate
function chunk_generate(_chunk)
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __skip_z_array = array_create(CHUNK_SIZE * CHUNK_SIZE);
    
    for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE; ++i)
    {
        __skip_z_array[@ i] = 0;
    }
    
    static __structure_sort = function(_a, _b)
    {
        return ((_a.x * 0xffff) + _a.y) - ((_b.x * 0xffff) + _b.y);
    }
    
    var __structure_array = global.structure_pool.query_range(
        _chunk.x - (TILE_SIZE / 2),
        _chunk.y - (TILE_SIZE / 2),
        _chunk.x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        _chunk.y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION
    );
    
    var _structure_rectangle_length = array_length(__structure_array);
    
    var _item_data = global.item_data;
    
    var _natural_structure_data = global.natural_structure_data;
    var _structure_data = global.structure_data;
    
    var _world_save_data = global.world_save_data;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    var _world_seed = _world_save_data.seed;
    
    var _surface_height_max = 10000;
    
    // Ensure worldgen config is updated for the current dimension (Moved to top)
    global.chunk_pool.worldgen_config = new WorldGenState(_world_data);
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        
        var _cave_bit = 0;
        
        for (var j = 0; j < CHUNK_SIZE + 2; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j - 1;
            
            if (!worldgen_is_solid(_world_x, _world_y, _world_seed))
            {
                _cave_bit |= 1 << j;
            }
        }
        
        __cave_bit[@ i] = _cave_bit;
    }
    
    static __pattern_scanner = new PatternScanner()
        .add_pattern(new PatternTreeRootOverCave());
        
    var _pattern_matches = __pattern_scanner.scan_chunk(_chunk, _world_data, _world_seed);
    if (array_length(_pattern_matches) > 0)
    {
        for (var p = 0; p < array_length(_pattern_matches); ++p)
        {
            var _match = _pattern_matches[p];
            
            _match.pattern.generate(_match.x, _match.y, _chunk);
        }
    }
    
    if (_structure_rectangle_length > 0)
    {
        array_sort(__structure_array, __structure_sort);
        
        for (var l = 0; l < _structure_rectangle_length; ++l)
        {
            var _inst = __structure_array[l];
            
            var _structure_x = _chunk.chunk_xstart - _inst.structure_xrelative;
            var _structure_y = _chunk.chunk_ystart - _inst.structure_yrelative;
            
            var _xscale = _inst.image_xscale;
            var _yscale = _inst.image_yscale;
            var _rectangle = _xscale * _yscale;
            
            var _structure_xstart = _inst.structure_xrelative;
            var _structure_ystart = _inst.structure_yrelative;
            
            var _rel_x = _inst.structure_xrelative - _chunk.chunk_xstart;
            var _rel_y = _inst.structure_yrelative - _chunk.chunk_ystart;
            
            var _sx_start = max(0, -_rel_x);
            var _sx_end = min(_xscale, CHUNK_SIZE - _rel_x);
            
            var _sy_start = max(0, -_rel_y);
            var _sy_end = min(_yscale, CHUNK_SIZE - _rel_y);
            
            if (_sx_start >= _sx_end) || (_sy_start >= _sy_end) continue;
            
            structure_generate(_inst, _world_seed, _item_data, _structure_data, _natural_structure_data);
            
            var _data = _inst.data;
            
            for (var _sy = _sy_start; _sy < _sy_end; ++_sy)
            {
                var _chunk_y = _rel_y + _sy;
                
                for (var _sx = _sx_start; _sx < _sx_end; ++_sx)
                {
                    var _chunk_x = _rel_x + _sx;
                    
                    var _structure_index = _sx + (_sy * _xscale);
                    var _chunk_index = _chunk_x + (_chunk_y * CHUNK_SIZE);
                    
                    for (var m = CHUNK_DEPTH - 1; m >= 0; --m)
                    {
                        var _tile = _data[_structure_index + (m * _rectangle)];
                        
                        if (_tile == TILE_STRUCTURE_VOID) continue;
                        
                        if ((1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT)))
                        {
                            __skip_z_array[@ _chunk_index] |= (1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT);
                        }
                        else
                        {
                            __skip_z_array[@ _chunk_index] |= 1 << m;
                        }
                        
                        _chunk.chunk[@ (m << (CHUNK_SIZE_BIT * 2)) | (_chunk_y << CHUNK_SIZE_BIT) | _chunk_x] = _tile;
                        
                        if (_tile != TILE_EMPTY)
                        {
                            ++_chunk.chunk_count[@ m];
                            _chunk.chunk_display |= 1 << m;
                        }
                        
                        var _ = _item_data[$ _tile.get_id()];
                        if ((1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_WALL))) && (_.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_.is_transparent())
                        {
                            _chunk.chunk_covered[@ _chunk_x] |= 1 << _chunk_y;
                        }
                    }
                    
                    if (++_inst.count >= _rectangle)
                    {
                        global.structure_pool.release(_inst);
                    }
                }
            }
        }
    }
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        var _inst_x = _world_x * TILE_SIZE;
        
        var _region = global.region_generator.get_region(_world_x, 0, 0, _world_seed);
        
        var _surface_height = undefined;
        
        var _surface_biome_id = _region.get_surface_biome_id();
        var _surface_biome_data = global.biome_data[$ _surface_biome_id];
        var _sea_level = 450;
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j;
            
            var _inst_y = _world_y * TILE_SIZE;
            var _skip_z = __skip_z_array[i + (j * CHUNK_SIZE)];
            
            var _is_cave = (__cave_bit[i] >> (j + 1)) & 1;
            var _is_cave_above = (__cave_bit[i] >> j) & 1;
            
            var _cave_biome = undefined;
            // Use implicit depth check or assume valid if we are here
            var _depth_from_surface = _world_y - (_world_data.get_surface_start());
            
            if (_depth_from_surface >= 8)
            {
                _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed);
            }
            
            if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && (!_is_cave)
            {
                var _tile_id = worldgen_get_tile_base(_world_x, _world_y, _surface_biome_id, _cave_biome, _surface_height, _is_cave_above, _world_seed);
                
                if (_tile_id != TILE_EMPTY)
                {
                    var _data = _item_data[$ _tile_id];
                    if (_data != undefined)
                    {
                        ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                        
                        var _index = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                        
                        _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_id).set_index(_index);
                        _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                        
                        if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                        {
                            _chunk.chunk_covered[@ i] |= 1 << j;
                        }
                    }
                }
            }
            
            if !(_skip_z & (1 << CHUNK_DEPTH_WALL))
            {
                var _wall_id = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome_id, _cave_biome, _surface_height, _world_seed, _is_cave_above);
                
                if (_wall_id != TILE_EMPTY)
                {
                    var _data = _item_data[$ _wall_id];
                    
                    if (_data != undefined)
                    {
                        ++_chunk.chunk_count[@ CHUNK_DEPTH_WALL];
                        
                        var _index = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                        
                        _chunk.chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_wall_id)
                            .set_index(_index);
                        
                        _chunk.chunk_display |= 1 << CHUNK_DEPTH_WALL;
                        
                        if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                        {
                            _chunk.chunk_covered[@ i] |= 1 << j;
                        }
                    }
                }
            }
            
            if (_is_cave) && !((__cave_bit[i] >> (j + 2)) & 1)
            {
                var _z = ((xorshift(_world_seed ^ (_world_x * 457)) & (1 << j)) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
                
                if !(_skip_z & (1 << _z)) 
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome_id, _cave_biome, _surface_height, true, _world_seed);
                    var _tile_foliage = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome_id, _cave_biome, _tile_base, _surface_height, _world_seed);
                    
                    if (_tile_foliage != TILE_EMPTY)
                    {
                        var _data = _item_data[$ _tile_foliage];
                        
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ _z];
                            
                            var _flip = (((_data.can_flip_on_x()) && (xorshift(_world_seed ^ (_world_x * 997)) & 1)) ? -1 : 1);
                            
                            var _index = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                            
                            _chunk.chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_foliage)
                                .set_index(_index)
                                .set_xscale(_flip);
                            
                            _chunk.chunk_display |= 1 << _z;
                        }
                    }
                }
            }
        }
        
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _occluded = 0;
            var _has_opaque_above = false;
            
            for (var _z = CHUNK_DEPTH_DEFAULT; _z >= CHUNK_DEPTH_WALL; --_z)
            {
                if (_has_opaque_above)
                {
                    _occluded |= (1 << _z);
                }
                
                var _tile = _chunk.chunk[tile_index_xyz(i, j, _z)];
                
                if (_tile != TILE_EMPTY)
                {
                    var _data = _item_data[$ _tile.get_id()];
                    
                    if (_data != undefined) && (!_data.is_transparent()) && (_data.has_type(ITEM_TYPE_BIT.SOLID))
                    {
                        _has_opaque_above = true;
                    }
                }
            }
            
            _chunk.chunk_occluded[@ tile_index_xy(i, j)] = _occluded;
        }
    }
    
    if (global.network_role == NETWORK_ROLE.CLIENT)
    {
        network_send_chunk_request(_chunk.x, _chunk.y);
    }
}