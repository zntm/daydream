/// @function chunk_generate(_chunk, _context = undefined)
/// @desc Generate terrain for a _chunk.chunk
/// @param {Struct.Chunk} _chunk The _chunk.chunk to generate
/// @param {Struct} [_context] Optional pre-calculated world-gen context
function chunk_generate(_chunk, _context = undefined)
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __sky_bit = array_create(CHUNK_SIZE);
    static __surface_height = array_create(CHUNK_SIZE);
    static __skip_z_array = array_create(CHUNK_SIZE * CHUNK_SIZE);
    
    // Clear skip_z array
    for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE; ++i) __skip_z_array[@ i] = 0;
    
    var _surface_height_max = 999999;
    
    static __structure_sort = function(_a, _b)
    {
        return ((_a.x * 0xffff) + _a.y) - ((_b.x * 0xffff) + _b.y);
    }
    
    var _structures = global.structure_pool.query_range(
        _chunk.x - (TILE_SIZE / 2),
        _chunk.y - (TILE_SIZE / 2),
        _chunk.x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        _chunk.y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION
    );
    var _structure_rectangle_length = array_length(_structures);
    var __structure_array = _structures;
    
    // Support data-driven value caching via context
    var _item_data, _natural_structure_data, _structure_data, _world_save_data, _world_data, _global_biome_data, _world_height, _world_seed, _sky_threshold, _sky_enabled;
    
    if (_context != undefined)
    {
        _item_data = _context.item_data;
        _natural_structure_data = _context.natural_structure_data;
        _structure_data = _context.structure_data;
        _world_save_data = _context.world_save_data;
        _world_data = _context.world_data;
        _global_biome_data = _context.biome_data;
        _world_height = _context.world_height;
        _world_seed = _context.world_seed;
        _sky_threshold = _context.sky_threshold;
        _sky_enabled = _context.sky_enabled;
    }
    else
    {
        _item_data = global.item_data;
        _natural_structure_data = global.natural_structure_data;
        _structure_data = global.structure_data;
        _world_save_data = global.world_save_data;
        _world_data = global.world_data[$ _world_save_data.dimension];
        _global_biome_data = global.biome_data;
        _world_height = _world_data.get_world_height();
        _world_seed = _world_save_data.seed;
        _sky_threshold = _world_data.get_sky_biome_threshold();
        _sky_enabled = _world_data.is_sky_biome_enabled();
    }

    
    // PASS 1: Calculate heights and bitmasks (Caves + Sky)
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        var _surface_height = worldgen_get_surface_height(_world_x, _world_seed, _world_data);
        
        __surface_height[@ i] = _surface_height;
        _surface_height_max = min(_surface_height_max, _surface_height);
        
        var _cave_bit = 0;
        var _sky_bit = 0;
        var _cave_start = worldgen_get_cave_start(_world_x, _world_seed, _world_data);
        
        for (var j = 0; j < CHUNK_SIZE + 2; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j - 1;
            
            // Cave Mask
            _cave_bit |= worldgen_get_cave(_world_x, _world_y, _surface_height, _cave_start, _world_seed, _world_data) << j;
            
            // Sky Mask (Only if in sky zone)
            if (_sky_enabled && _world_y <= _sky_threshold)
            {
                if (worldgen_get_sky_island(_world_x, _world_y, _world_seed, _world_data))
                {
                    _sky_bit |= (1 << j);
                }
            }
        }
        
        __cave_bit[@ i] = _cave_bit;
        __sky_bit[@ i] = _sky_bit;
    }
    
    // Initialize structures
    for (var i = 0; i < _structure_rectangle_length; ++i)
    {
        structure_generate(__structure_array[i], _world_seed, _item_data, _structure_data, _natural_structure_data);
    }
    
    // Early exit if chunk is empty
    var _in_sky_zone = (_chunk.chunk_ystart <= _sky_threshold) && _sky_enabled;
    if (_structure_rectangle_length <= 0) && (_surface_height_max > _chunk.chunk_ystart + CHUNK_SIZE - 1) && (!_in_sky_zone) exit;
    
    // NEW SYSTEM: Pattern Scanner Pass (from Old Version)
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
    
    // Apply Structures to Chunk
    if (_structure_rectangle_length > 0)
    {
        array_sort(__structure_array, __structure_sort);
        for (var l = 0; l < _structure_rectangle_length; ++l)
        {
            var _inst = __structure_array[l];
            var _xscale = _inst.image_xscale;
            var _yscale = _inst.image_yscale;
            var _rectangle = _xscale * _yscale;
            var _data = _inst.data;
            
            var _rel_x = _inst.structure_xrelative - _chunk.chunk_xstart;
            var _rel_y = _inst.structure_yrelative - _chunk.chunk_ystart;
            
            var _sx_start = max(0, -_rel_x);
            var _sx_end = min(_xscale, CHUNK_SIZE - _rel_x);
            var _sy_start = max(0, -_rel_y);
            var _sy_end = min(_yscale, CHUNK_SIZE - _rel_y);
            
            if (_sx_start >= _sx_end || _sy_start >= _sy_end) continue;
            
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
                        
                        var _mask = (1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT));
                        if (_mask) __skip_z_array[@ _chunk_index] |= (1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT);
                        else __skip_z_array[@ _chunk_index] |= 1 << m;
                        
                        _chunk.chunk[@ (m << (CHUNK_SIZE_BIT * 2)) | (_chunk_y << CHUNK_SIZE_BIT) | _chunk_x] = _tile;
                        
                        if (_tile != TILE_EMPTY)
                        {
                            ++_chunk.chunk_count[@ m];
                            _chunk.chunk_display |= 1 << m;
                        }
                        
                        var _item = _item_data[$ _tile.get_id()];
                        if ((1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_WALL))) && (_item.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_item.is_transparent())
                        {
                            _chunk.chunk_covered[@ _chunk_x] |= 1 << _chunk_y;
                        }
                    }
                }
            }
            if (++_inst.count >= _rectangle) global.structure_pool.release(_inst);
        }
    }
    
    // PASS 2: Terrain Generation
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        var _surface_height = __surface_height[i];
        var _cave_bit_stream = __cave_bit[i];
        var _sky_bit_stream = __sky_bit[i];
        
        var _xorshift_val = xorshift(_world_seed ^ ((_world_x + _chunk.chunk_ystart) * _surface_height));
        
        // HOIST: Biome Parameters (per column)
        var _heat = worldgen_get_heat(_world_x, _surface_height, _world_seed, _world_data);
        var _humidity = worldgen_get_humidity(_world_x, _surface_height, _world_seed, _world_data);
        var _surface_biome = worldgen_get_biome_surface(_world_x, _surface_height, _surface_height, _world_seed, _world_data, _heat, _humidity);
        var _surface_biome_data = _global_biome_data[$ _surface_biome];
        
        // HOIST: Biome Blending Helpers (avoid 6 calls per tile)
        var _blend_range = (_context != undefined) ? _context.blend_range : _world_data.get_biome_blend_range();
        var _heat_l = worldgen_get_heat(_world_x - _blend_range, _surface_height, _world_seed, _world_data);
        var _heat_r = worldgen_get_heat(_world_x + _blend_range, _surface_height, _world_seed, _world_data);
        var _humid_l = worldgen_get_humidity(_world_x - _blend_range, _surface_height, _world_seed, _world_data);
        var _humid_r = worldgen_get_humidity(_world_x + _blend_range, _surface_height, _world_seed, _world_data);
        
        var _sky_biome_id = (_context != undefined) ? _context.sky_biome_id : _world_data.get_sky_biome_id();
        var _sky_biome_data = (_context != undefined) ? _context.sky_biome_data : _global_biome_data[$ _sky_biome_id];
        var _world_surface_start = (_context != undefined) ? _context.surface_start : _world_data.get_surface_start();
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j;
            var _skip_z = __skip_z_array[i + (j * CHUNK_SIZE)];
            
            // --- SKY BIOME (Optimized via __sky_bit) ---
            if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && (_world_y <= _sky_threshold) && _sky_enabled
            {
                if ((_sky_bit_stream >> (j + 1)) & 1)
                {
                    if (_sky_biome_data != undefined)
                    {
                        var _is_above = (_sky_bit_stream >> j) & 1;
                        var _is_below = (_sky_bit_stream >> (j + 2)) & 1;
                        
                        var _tile_seed = abs(_world_x * 73856093) ^ abs(_world_y * 19349663) ^ _world_seed;
                        var _tile_id = (!_is_above ? _sky_biome_data.get_tile_top_layer_base(_tile_seed) : 
                                       (!_is_below ? _sky_biome_data.get_tile_bottom_layer_base(_tile_seed) : 
                                       _sky_biome_data.get_tile_middle_layer_base(_tile_seed)));
                        
                        if (_tile_id != TILE_EMPTY)
                        {
                            var _d = _item_data[$ _tile_id];
                            if (_d != undefined)
                            {
                                ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                                _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_id)
                                    .set_index(smart_value(_d.get_placement_index()))
                                    .set_index_offset(smart_value(_d.get_placement_index_offset()));
                                _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                                if (_d.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_d.is_transparent()) _chunk.chunk_covered[@ i] |= 1 << j;
                            }
                        }
                    }
                }
            }
            
            // --- OCEAN WATER ---
            if (_world_y < _surface_height) && (_world_y >= _world_surface_start) && (_surface_biome_data.is_ocean())
            {
                if !(_skip_z & (1 << CHUNK_DEPTH_LIQUID))
                {
                    var _water_id = "phantasia:water";
                    var _water_data = _item_data[$ _water_id];
                    if (_water_data != undefined)
                    {
                        ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                        _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_water_id).set_component("level", 8);
                        _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                    }
                }
            }
            
            // --- CAVES AND SOLID TERRAIN ---
            if (_world_y >= _surface_height - 1)
            {
                var _heat_c = worldgen_get_cave_heat(_world_x, _world_y, _world_seed, _world_data);
                var _humid_c = worldgen_get_cave_humidity(_world_x, _world_y, _world_seed, _world_data);
                var _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed, _world_data, _heat_c, _humid_c);
                var _is_cave = (_cave_bit_stream >> (j + 1)) & 1;
                
                if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && !_is_cave && _world_y >= _surface_height
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, (_cave_bit_stream >> j) & 1, _world_seed, _world_data, _global_biome_data, _heat, _humidity);
                    if (_tile_base != TILE_EMPTY)
                    {
                        var _d = _item_data[$ _tile_base];
                        if (_d != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                            _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_base)
                                .set_index(smart_value(_d.get_placement_index()))
                                .set_index_offset(smart_value(_d.get_placement_index_offset()));
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                            if (_d.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_d.is_transparent()) _chunk.chunk_covered[@ i] |= 1 << j;
                        }
                    }
                }
                
                if !(_skip_z & (1 << CHUNK_DEPTH_WALL)) && _world_y >= _surface_height
                {
                    var _tile_wall = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _world_seed, _world_data, _global_biome_data);
                    if (_tile_wall != TILE_EMPTY)
                    {
                        var _d = _item_data[$ _tile_wall];
                        if (_d != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_WALL];
                            _chunk.chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_wall)
                                .set_index(smart_value(_d.get_placement_index()))
                                .set_index_offset(smart_value(_d.get_placement_index_offset()));
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_WALL;
                            if (_d.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_d.is_transparent()) _chunk.chunk_covered[@ i] |= 1 << j;
                        }
                    }
                }
                
                // --- AQUIFERS ---
                if !(_skip_z & (1 << CHUNK_DEPTH_LIQUID)) && _is_cave
                {
                    var _aquifer = worldgen_get_aquifer(_world_x, _world_y, _surface_height, _world_seed, _world_data);
                    if (_aquifer != undefined)
                    {
                        var _d = _item_data[$ _aquifer.type];
                        if (_d != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                            _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_aquifer.type).set_component("level", _aquifer.fill_level);
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                        }
                    }
                    else if (_world_height - _world_y <= 32 && _world_height - _world_y > 3)
                    {
                        var _lava_id = "phantasia:lava";
                        var _lava_d = _item_data[$ _lava_id];
                        if (_lava_d != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                            _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_lava_id).set_component("level", 8);
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                        }
                    }
                }
            }
            
            // --- FOLIAGE ---
            var _foliage_layer = ((_xorshift_val & (1 << j)) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
            if !(_skip_z & (1 << _foliage_layer)) && (_world_y >= _surface_height - 1)
            {
                var _is_floor = (_cave_bit_stream >> (j + 1)) & 1 && !((_cave_bit_stream >> (j + 2)) & 1);
                if (_is_floor)
                {
                    var _tile_next = worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome, undefined, _surface_height, true, _world_seed, _world_data, _global_biome_data, _heat, _humidity);
                    var _foliage_id = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome, undefined, _tile_next, _surface_height, _world_seed, _global_biome_data);
                    
                    if (_foliage_id != TILE_EMPTY)
                    {
                        var _d = _item_data[$ _foliage_id];
                        if (_d != undefined)
                        {
                            ++_chunk.chunk_count[@ _foliage_layer];
                            var _flip = ((_d.can_flip_on_x()) && (_xorshift_val & (1 << (CHUNK_SIZE + j)))) ? -1 : 1;
                            _chunk.chunk[@ (_foliage_layer << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_foliage_id)
                                .set_xscale(_flip)
                                .set_index(smart_value(_d.get_placement_index()))
                                .set_index_offset(smart_value(_d.get_placement_index_offset()));
                            _chunk.chunk_display |= 1 << _foliage_layer;
                        }
                    }
                }
            }
        }
    }
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
}