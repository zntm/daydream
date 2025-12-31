/// @function chunk_generate(_chunk)
/// @desc Generate terrain for a _chunk.chunk
/// @param {Struct.Chunk} _chunk The _chunk.chunk to generate
function chunk_generate(_chunk)
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __surface_height = array_create(CHUNK_SIZE);
    static __skip_z_array = array_create(CHUNK_SIZE * CHUNK_SIZE);
    
    // Clear skip_z array
    for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE; ++i) __skip_z_array[@ i] = 0;
    
    var _surface_height_max = 999999;
    
    static __structure_sort = function(_a, _b)
    {
        return ((_a.x * 0xffff) + _a.y) - ((_b.x * 0xffff) + _b.y);
    }
    
    static __structure_list_rectangle = ds_list_create();
    static __structure_list = ds_list_create();
    
    static __structure_array = [];
    
    // Collect structures first
    var _structure_rectangle_length = collision_rectangle_list(
        _chunk.x - (TILE_SIZE / 2),
        _chunk.y - (TILE_SIZE / 2),
        _chunk.x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        _chunk.y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION,
        obj_Structure,
        false,
        true,
        __structure_list_rectangle,
        false
    );
    
    var _item_data = global.item_data;
    
    var _natural_structure_data = global.natural_structure_data;
    var _structure_data = global.structure_data;
    
    var _world_save_data = global.world_save_data;
    
    // Copy structure list to array for easier access
    array_resize(__structure_array, _structure_rectangle_length);
    for (var i = 0; i < _structure_rectangle_length; ++i)
    {
        __structure_array[@ i] = __structure_list_rectangle[| i];
    }
    // Sort logic handled later if needed, but structure_data access needs array/list
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    var _world_seed = _world_save_data.seed;
    
    // Calculate heights and apply structure modifiers
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        
        // Pass cached world_data
        var _surface_height = worldgen_get_surface_height(_world_x, _world_seed, _world_data);
        
        // Apply structure terrain modifiers
        if (_structure_rectangle_length > 0)
        {
            _surface_height = worldgen_apply_structure_terrain_modifier(_world_x, _surface_height, __structure_array, _structure_data);
        }
        
        var _cave_start = worldgen_get_cave_start(_world_x, _world_seed, _world_data);
        
        __surface_height[@ i] = _surface_height;
        
        _surface_height_max = min(_surface_height_max, _surface_height);
        
        var _cave_bit = 0;
        
        for (var j = 0; j < CHUNK_SIZE + 2; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j - 1;
            
            // Pass cached world_data
            _cave_bit |= worldgen_get_cave(_world_x, _world_y, _surface_height, _cave_start, _world_seed, _world_data) << j;
        }
        
        __cave_bit[@ i] = _cave_bit;
    }
    
    // Initialize structures
    for (var i = 0; i < _structure_rectangle_length; ++i)
    {
        structure_generate(__structure_array[i], _world_seed, _item_data, _structure_data, _natural_structure_data);
    }
    
    // Check if _chunk.chunk is empty (above surface and no structures)
    // ALSO check if _chunk.chunk is in sky biome zone - don't skip those
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    var _in_sky_zone = (_chunk.chunk_ystart <= _sky_threshold) && _world_data.is_sky_biome_enabled();
    
    if (_structure_rectangle_length <= 0) && (_surface_height_max > _chunk.chunk_ystart + CHUNK_SIZE - 1) && (!_in_sky_zone) exit;
    
    // Sort and Push structures to _chunk.chunk
    if (_structure_rectangle_length > 0)
    {
        array_sort(__structure_array, __structure_sort);
        
        for (var l = 0; l < _structure_rectangle_length; ++l)
        {
            var _inst = __structure_array[l];
            
            // Calculate relative position of structure to this _chunk.chunk
            var _structure_x = _chunk.chunk_xstart - _inst.structure_xrelative;
            var _structure_y = _chunk.chunk_ystart - _inst.structure_yrelative;
            
            var _xscale = _inst.image_xscale;
            var _yscale = _inst.image_yscale;
            var _rectangle = _xscale * _yscale;
            var _data = _inst.data;
            
            var _structure_xstart = _inst.structure_xrelative;
            var _structure_ystart = _inst.structure_yrelative;
            
            // Iterate over the structure bounds
            for (var _sy = 0; _sy < _yscale; ++_sy)
            {
                var _chunk_y = _structure_ystart + _sy - _chunk.chunk_ystart;
                if (_chunk_y < 0 || _chunk_y >= CHUNK_SIZE) continue;
                
                for (var _sx = 0; _sx < _xscale; ++_sx)
                {
                    var _chunk_x = _structure_xstart + _sx - _chunk.chunk_xstart;
                    if (_chunk_x < 0 || _chunk_x >= CHUNK_SIZE) continue;
                    
                    var _structure_index = _sx + (_sy * _xscale);
                    var _chunk_index = _chunk_x + (_chunk_y * CHUNK_SIZE); // i + j*32
                    
                    for (var m = CHUNK_DEPTH - 1; m >= 0; --m)
                    {
                        var _tile = _data[_structure_index + (m * _rectangle)];
                        
                        if (_tile == TILE_STRUCTURE_VOID) continue;
                        
                        // Update skip_z mask
                        if ((1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT)))
                        {
                            __skip_z_array[@ _chunk_index] |= (1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT);
                        }
                        else
                        {
                            __skip_z_array[@ _chunk_index] |= 1 << m;
                        }
                        
                        // Write tile to _chunk.chunk
                        // Chunk array index: (Depth << 10) | (Y << 5) | X
                        // Y is _chunk_y (j), X is _chunk_x (i)
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
                }
            }
            
            if (++_inst.count >= _rectangle)
            {
                instance_destroy(_inst);
            }
        }
    }
    
    ds_list_clear(__structure_list_rectangle);
    ds_list_clear(__structure_list); // clean up this list too just in case
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        
        var _inst_x = _world_x * TILE_SIZE;
        
        var _surface_height = __surface_height[i];
        
        var _cave_bit = __cave_bit[i];
        
        var _xorshift = xorshift(_world_seed ^ ((_world_x + _chunk.chunk_ystart) * _surface_height));
        
        // Hoisted optimizations
        var _heat_surface = worldgen_get_heat(_world_x, 0, _world_seed, _world_data);
        var _humidity_surface = worldgen_get_humidity(_world_x, 0, _world_seed, _world_data);
        
        var _surface_biome = worldgen_get_biome_surface(_world_x, 0, _surface_height, _world_seed, _world_data, _heat_surface, _humidity_surface);
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j;
            
            // Calculate cave biome parameters at this depth
            var _heat_cave = worldgen_get_cave_heat(_world_x, _world_y, _world_seed, _world_data);
            var _humidity_cave = worldgen_get_cave_humidity(_world_x, _world_y, _world_seed, _world_data);

            
            var _inst_y = _world_y * TILE_SIZE;
            
            var _skip_z = __skip_z_array[i + (j * CHUNK_SIZE)];
            
            var _cave_biome = undefined;
            var _biome_data = global.biome_data[$ _surface_biome];
            var _sea_level = _world_data.get_surface_start();  // Use world surface start as sea level
            
            // Sky biome generation: check if this position is part of a sky biome
            var _sky_biome_threshold = _world_data.get_sky_biome_threshold();
            if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && (_world_y <= _sky_biome_threshold) && _world_data.is_sky_biome_enabled()
            {
                var _is_sky_biome = worldgen_get_sky_island(_world_x, _world_y, _world_seed, _world_data);
                
                if (_is_sky_biome)
                {
                    // Use sky biome data
                    var _sky_biome_data = global.biome_data[$ _world_data.get_sky_biome_id()];
                    
                    if (_sky_biome_data != undefined)
                    {
                        // Determine tile based on vertical position within island
                        // Check if above/below are also island to determine layer
                        var _is_above_sky = worldgen_get_sky_island(_world_x, _world_y - 1, _world_seed, _world_data);
                        var _is_below_sky = worldgen_get_sky_island(_world_x, _world_y + 1, _world_seed, _world_data);
                        
                        var _tile_seed = abs(_world_x * 73856093) ^ abs(_world_y * 19349663) ^ _world_seed;
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
                            var _data = _item_data[$ _tile_id];
                            
                            if (_data != undefined)
                            {
                                ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                                
                                _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_id)
                                    .set_index(smart_value(_data.get_placement_index()))
                                    .set_index_offset(smart_value(_data.get_placement_index_offset()));
                                
                                _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                                
                                if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                                {
                                    _chunk.chunk_covered[@ i] |= 1 << j;
                                }
                            }
                        }
                    }
                }
            }
            
            // Ocean water fill: if above terrain but below sea level in ocean biome
            if (_world_y < _surface_height) && (_world_y >= _sea_level) && (_biome_data.is_ocean())
            {
                if !(_skip_z & (1 << CHUNK_DEPTH_LIQUID))
                {
                    var _water_id = "phantasia:water";
                    var _water_data = _item_data[$ _water_id];
                    
                    if (_water_data != undefined)
                    {
                        ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                        
                        _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_water_id)
                            .set_component("level", 8);
                        
                        _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                    }
                }
            }
            
            if (_world_y >= _surface_height)
            {
                _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed, _world_data, _heat_cave, _humidity_cave);
                
                if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && !(_cave_bit & (1 << (j + 1)))
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _cave_bit & (1 << j), _world_seed);
                    
                    if (_tile_base != TILE_EMPTY)
                    {
                        var _id = _tile_base;
                        var _data = _item_data[$ _id];
                        
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                            
                            _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_index(smart_value(_data.get_placement_index()))
                                .set_index_offset(smart_value(_data.get_placement_index_offset()));
                            
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
                    var _tile_wall = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome, _cave_biome, _surface_height, _world_seed);
                    
                    if (_tile_wall != TILE_EMPTY)
                    {
                        var _id = _tile_wall;
                        var _data = _item_data[$ _id];
                        
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_WALL];
                            
                            _chunk.chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_index(smart_value(_data.get_placement_index()))
                                .set_index_offset(smart_value(_data.get_placement_index_offset()));
                            
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_WALL;
                            
                            if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                            {
                                _chunk.chunk_covered[@ i] |= 1 << j;
                            }
                        }
                    }
                }
                
                // Aquifer liquid placement: check if this cave position should have liquid
                if !(_skip_z & (1 << CHUNK_DEPTH_LIQUID)) && (_cave_bit & (1 << (j + 1)))
                {
                    var _aquifer = worldgen_get_aquifer(_world_x, _world_y, _surface_height, _world_seed, _world_data);
                    
                    if (_aquifer != undefined)
                    {
                        var _id = _aquifer.type;
                        var _data = _item_data[$ _id];
                        
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                            
                            _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_component("level", _aquifer.fill_level);
                            
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                        }
                    }
                    else
                    {
                        // Lava ocean: fill deep cave voids with lava (bottom 32 tiles)
                        static __LAVA_OCEAN_DEPTH = 32;
                        var _depth_from_bottom = _world_height - _world_y;
                        
                        if (_depth_from_bottom <= __LAVA_OCEAN_DEPTH && _depth_from_bottom > 3)
                        {
                            var _lava_id = "phantasia:lava";
                            var _lava_data = _item_data[$ _lava_id];
                            
                            if (_lava_data != undefined)
                            {
                                ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                                
                                _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_lava_id)
                                    .set_component("level", 8);
                                
                                _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                            }
                        }
                    }
                }
            }
            
            var _z = ((_xorshift & (1 << j)) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
            
            if !(_skip_z & (1 << _z)) && (_world_y >= _surface_height - 1)
            {
                var _cave_biome_next = worldgen_get_biome_cave(_world_x, _world_y + 1, _surface_height, _world_seed, _world_data, _heat_cave, _humidity_cave);
                
                if (_cave_bit & (1 << (j + 1))) && !(_cave_bit & (1 << (j + 2)))
                {
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome, _cave_biome_next, _surface_height, true, _world_seed);
                    
                    var _tile_foliage = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome, _cave_biome, _tile_base, _surface_height, _world_seed);
                    
                    if (_tile_foliage != TILE_EMPTY)
                    {
                        var _id = _tile_foliage;
                        var _data = _item_data[$ _id];
                        
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ _z];
                            
                            _chunk.chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_xscale(((_data.can_flip_on_x()) && (_xorshift & (1 << (CHUNK_SIZE + j)))) ? -1 : 1)
                                .set_index(smart_value(_data.get_placement_index()))
                                .set_index_offset(smart_value(_data.get_placement_index_offset()));
                            
                            _chunk.chunk_display |= 1 << _z;
                        }
                    }
                }
            }
        }
        
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
}