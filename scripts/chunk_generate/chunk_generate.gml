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
    
    // =========================================================================
    // OPTIMIZATION: Hoist all world_data parameters used in hot loops
    // These are called thousands of times per chunk, so avoid repeated lookups.
    // =========================================================================
    
    // Cave system parameters
    var _cave_noise_scale = _world_data.get_cave_noise_scale();
    var _cave_system = _world_data.get_cave_system();
    var _cave_system_length = _world_data.get_cave_system_length();
    var _cave_depth_smoothing = _world_data.get_cave_depth_smoothing();
    
    // Cave breach parameters
    var _cave_breach_depth = _world_data.get_cave_breach_depth();
    var _cave_breach_noise_scale_x = _world_data.get_cave_breach_noise_scale_x();
    var _cave_breach_noise_scale_y = _world_data.get_cave_breach_noise_scale_y();
    var _cave_breach_noise_offset_y = _world_data.get_cave_breach_noise_offset_y();
    var _cave_breach_noise_range = _world_data.get_cave_breach_noise_range();
    var _cave_breach_noise_octaves = _world_data.get_cave_breach_noise_octaves();
    var _cave_breach_threshold = _world_data.get_cave_breach_threshold();
    
    // Cave heat/humidity parameters
    var _cave_biome_heat_data = _world_data.get_cave_biome_heat();
    var _cave_heat_enabled = (_cave_biome_heat_data != undefined);
    var _cave_heat_noise_scale_x = _cave_heat_enabled ? _world_data.get_cave_heat_noise_scale_x() : 0;
    var _cave_heat_noise_scale_y = _cave_heat_enabled ? _world_data.get_cave_heat_noise_scale_y() : 0;
    var _cave_heat_range = _cave_heat_enabled ? _world_data.get_cave_heat_range() : 0;
    var _cave_heat_octaves = _cave_heat_enabled ? _cave_biome_heat_data.octaves : 0;
    
    var _cave_biome_humidity_data = _world_data.get_cave_biome_humidity();
    var _cave_humidity_enabled = (_cave_biome_humidity_data != undefined);
    var _cave_humidity_noise_scale_x = _cave_humidity_enabled ? _world_data.get_cave_humidity_noise_scale_x() : 0;
    var _cave_humidity_noise_scale_y = _cave_humidity_enabled ? _world_data.get_cave_humidity_noise_scale_y() : 0;
    var _cave_humidity_offset_y = _cave_humidity_enabled ? _world_data.get_cave_humidity_offset_y() : 0;
    var _cave_humidity_range = _cave_humidity_enabled ? _world_data.get_cave_humidity_range() : 0;
    var _cave_humidity_octaves = _cave_humidity_enabled ? (_cave_biome_humidity_data.octaves + _world_data.get_cave_humidity_octaves_offset()) : 0;
    
    // Surface biome parameters
    var _surface_biome_octaves = _world_data.get_surface_biome_heat().octaves;
    var _surface_heat_noise_scale = _world_data.get_surface_heat_noise_scale();
    var _surface_heat_offset = _world_data.get_surface_heat_offset();
    var _surface_heat_range = _world_data.get_surface_heat_range();
    var _surface_heat_spline_x = _world_data.get_surface_heat_spline_x();
    var _surface_heat_spline_y = _world_data.get_surface_heat_spline_y();
    
    var _surface_humidity_octaves = _world_data.get_surface_biome_humidity().octaves;
    var _surface_humidity_noise_scale = _world_data.get_surface_humidity_noise_scale();
    var _surface_humidity_offset = _world_data.get_surface_humidity_offset();
    var _surface_humidity_range = _world_data.get_surface_humidity_range();
    var _surface_humidity_spline_x = _world_data.get_surface_humidity_spline_x();
    var _surface_humidity_spline_y = _world_data.get_surface_humidity_spline_y();
    
    var _surface_biome_map = _world_data.get_surface_biome_map();
    var _surface_min_depth = _world_data.get_surface_min_depth();
    var _surface_start = _world_data.get_surface_start();
    
    // Cave biome parameters
    var _cave_biome_map = _world_data.get_cave_biome_map();
    var _cave_biome_depth_zones = _world_data.get_cave_biome_depth_zones();
    var _cave_biome_depth_zones_length = _world_data.get_cave_biome_depth_zones_length();
    
    // Sky biome parameters
    var _sky_biome_enabled = _world_data.is_sky_biome_enabled();
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    var _sky_biome_id = _sky_biome_enabled ? _world_data.get_sky_biome_id() : undefined;
    
    // Sky island generation parameters (hoisted)
    var _sky_island_spacing = _sky_biome_enabled ? _world_data.get_sky_island_spacing() : 0;
    var _sky_island_radius = _sky_biome_enabled ? _world_data.get_sky_island_radius() : 0;
    var _sky_island_thickness = _sky_biome_enabled ? _world_data.get_sky_island_thickness() : 0;
    var _sky_noise_region_scale = _sky_biome_enabled ? _world_data.get_sky_noise_scale_region() : 0;
    var _sky_region_offset_y = _sky_biome_enabled ? _world_data.get_sky_region_offset_y() : 0;
    var _sky_region_range = _sky_biome_enabled ? _world_data.get_sky_region_range() : 0;
    var _sky_region_octaves = _sky_biome_enabled ? _world_data.get_sky_region_octaves() : 0;
    var _sky_region_threshold = _sky_biome_enabled ? _world_data.get_sky_region_threshold() : 0;
    var _sky_noise_edge_scale = _sky_biome_enabled ? _world_data.get_sky_noise_scale_edge() : 0;
    var _sky_edge_noise_amplitude = _sky_biome_enabled ? _world_data.get_sky_edge_noise_amplitude() : 0;
    var _sky_edge_noise_octaves = _sky_biome_enabled ? _world_data.get_sky_edge_noise_octaves() : 0;
    var _sky_noise_detail_scale = _sky_biome_enabled ? _world_data.get_sky_noise_scale_detail() : 0;
    var _sky_detail_noise_amplitude = _sky_biome_enabled ? _world_data.get_sky_detail_noise_amplitude() : 0;
    var _sky_detail_noise_octaves = _sky_biome_enabled ? _world_data.get_sky_detail_noise_octaves() : 0;
    
    // Aquifer parameters
    var _aquifers = _world_data.get_aquifers();
    var _aquifers_length = _world_data.get_aquifers_length();
    
    // Bedrock parameters
    var _bedrock_depth = _world_data.get_bedrock_depth();
    var _bedrock_noise_scale = _world_data.get_bedrock_noise_scale();
    
    // Tile variation / blend parameters
    var _tile_variation_noise_scale = _world_data.get_tile_variation_noise_scale();
    var _biome_blend_range = _world_data.get_biome_blend_range();
    var _biome_blend_noise_scale = _world_data.get_biome_blend_noise_scale();
    
    // Default cave biomes for fallback
    var _default_caves = _world_data.get_cave_biome_default();
    var _default_caves_length = array_length(_default_caves);
    
    // Biome data lookup
    var _biome_data_struct = global.biome_data;
    
    // =========================================================================
    // OPTIMIZATION: Inline helper function for cave generation
    // This avoids function call overhead and uses hoisted parameters.
    // =========================================================================
    /// @ignore
    static __get_cave_inline = function(
        _x, _y, _surface_height, _cave_start, _seed, _world_data,
        _cave_depth_smoothing, _cave_system, _cave_system_length, _cave_noise_scale,
        _cave_breach_depth, _cave_breach_noise_scale_x, _cave_breach_noise_scale_y, _cave_breach_noise_offset_y,
        _cave_breach_noise_range, _cave_breach_noise_octaves, _cave_breach_threshold
    )
    {
        var _depth_from_surface = _y - _surface_height;
        
        if (_depth_from_surface < 0)
        {
            if (_depth_from_surface > _cave_breach_depth)
            {
                var _breach_noise = open_simplex_noise(_x * _cave_breach_noise_scale_x, _surface_height * _cave_breach_noise_scale_y + _cave_breach_noise_offset_y, _cave_breach_noise_range, _cave_breach_noise_octaves);
                if (_breach_noise > _cave_breach_threshold)
                {
                    // Need to call recursively for the "cave below" check - keep this one simple
                    var _cave_below = worldgen_get_cave(_x, _surface_height + 2, _surface_height, _cave_start, _seed, _world_data);
                    if (_cave_below)
                    {
                        return true;
                    }
                }
            }
            return true;
        }
        
        var _depth_factor = spline_evaluate(_cave_depth_smoothing, _depth_from_surface);
        if (_depth_factor <= 0) return false;
        
        var _x_noise = _x * _cave_noise_scale;
        var _y_noise = _y * _cave_noise_scale;
        
        for (var __i = 0; __i < _cave_system_length; ++__i)
        {
            var __ = _cave_system[__i];
            var __octaves = __.threshold.octaves;
            var __noise = open_simplex_noise(_x_noise, _y_noise + ((0xffff * (__i + 1)) + 8), 0xff, __octaves);
            var __range_center = (__.range_min + __.range_max) / 2;
            var __range_half = ((__.range_max - __.range_min) / 2) * _depth_factor;
            if (__noise >= __range_center - __range_half) && (__noise < __range_center + __range_half)
            {
                return true;
            }
        }
        return false;
    };
    
    // =========================================================================
    // OPTIMIZATION: Inline helper function for cave heat
    // =========================================================================
    /// @ignore
    static __get_cave_heat_inline = function(_x, _y, _enabled, _scale_x, _scale_y, _range, _octaves)
    {
        if (!_enabled) return 0;
        return round(open_simplex_noise(_x * _scale_x, _y * _scale_y, _range, _octaves));
    };
    
    // =========================================================================
    // OPTIMIZATION: Inline helper function for cave humidity
    // =========================================================================
    /// @ignore
    static __get_cave_humidity_inline = function(_x, _y, _enabled, _scale_x, _scale_y, _offset_y, _range, _octaves)
    {
        if (!_enabled) return 0;
        return round(open_simplex_noise(_x * _scale_x, _y * _scale_y + _offset_y, _range, _octaves));
    };
    
    // =========================================================================
    // OPTIMIZATION: Inline helper function for surface heat
    // =========================================================================
    /// @ignore
    static __get_heat_inline = function(_x, _y, _noise_scale, _offset, _range, _octaves, _spline_x, _spline_y)
    {
        var __noise = open_simplex_noise(_x * _noise_scale, _offset, _range, _octaves);
        var __gradient = 0;
        if (_spline_x != undefined) __gradient += spline_evaluate(_spline_x, _x);
        if (_spline_y != undefined) __gradient += spline_evaluate(_spline_y, _y);
        return clamp(round(__noise + (__gradient * _range)), 0, _range);
    };
    
    // =========================================================================
    // OPTIMIZATION: Inline helper function for surface humidity
    // =========================================================================
    /// @ignore
    static __get_humidity_inline = function(_x, _y, _noise_scale, _offset, _range, _octaves, _spline_x, _spline_y)
    {
        var __noise = open_simplex_noise(_x * _noise_scale, _offset, _range, _octaves);
        var __gradient = 0;
        if (_spline_x != undefined) __gradient += spline_evaluate(_spline_x, _x);
        if (_spline_y != undefined) __gradient += spline_evaluate(_spline_y, _y);
        return clamp(round(__noise + (__gradient * _range)), 0, _range);
    };
    
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
            
            // INLINED cave check using hoisted parameters
            _cave_bit |= __get_cave_inline(
                _world_x, _world_y, _surface_height, _cave_start, _world_seed, _world_data,
                _cave_depth_smoothing, _cave_system, _cave_system_length, _cave_noise_scale,
                _cave_breach_depth, _cave_breach_noise_scale_x, _cave_breach_noise_scale_y, _cave_breach_noise_offset_y,
                _cave_breach_noise_range, _cave_breach_noise_octaves, _cave_breach_threshold
            ) << j;
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
    var _in_sky_zone = (_chunk.chunk_ystart <= _sky_threshold) && _sky_biome_enabled;
    
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
        
        // INLINED surface heat/humidity using hoisted parameters
        var _heat_surface = __get_heat_inline(_world_x, 0, _surface_heat_noise_scale, _surface_heat_offset, _surface_heat_range, _surface_biome_octaves, _surface_heat_spline_x, _surface_heat_spline_y);
        var _humidity_surface = __get_humidity_inline(_world_x, 0, _surface_humidity_noise_scale, _surface_humidity_offset, _surface_humidity_range, _surface_humidity_octaves, _surface_humidity_spline_x, _surface_humidity_spline_y);
        
        // INLINED surface biome lookup
        var _surface_biome = _surface_biome_map[(_humidity_surface << WORLDGEN_SIZE_HEAT_BIT) | (_heat_surface)];
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j;
            
            // INLINED cave heat/humidity using hoisted parameters
            var _heat_cave = __get_cave_heat_inline(_world_x, _world_y, _cave_heat_enabled, _cave_heat_noise_scale_x, _cave_heat_noise_scale_y, _cave_heat_range, _cave_heat_octaves);
            var _humidity_cave = __get_cave_humidity_inline(_world_x, _world_y, _cave_humidity_enabled, _cave_humidity_noise_scale_x, _cave_humidity_noise_scale_y, _cave_humidity_offset_y, _cave_humidity_range, _cave_humidity_octaves);

            
            var _inst_y = _world_y * TILE_SIZE;
            
            var _skip_z = __skip_z_array[i + (j * CHUNK_SIZE)];
            
            var _cave_biome = undefined;
            var _biome_data = _biome_data_struct[$ _surface_biome];
            var _sea_level = _surface_start;  // Use world surface start as sea level
            
            // Sky biome generation: check if this position is part of a sky biome
            if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT)) && (_world_y <= _sky_threshold) && _sky_biome_enabled
            {
                var _is_sky_biome = worldgen_get_sky_island(_world_x, _world_y, _world_seed, _world_data);
                
                if (_is_sky_biome)
                {
                    // Use sky biome data
                    var _sky_biome_data = _biome_data_struct[$ _sky_biome_id];
                    
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
                                
                                // OPTIMIZATION: Inline smart_value check
                                var _placement_index = _data.get_placement_index();
                                var _placement_index_offset = _data.get_placement_index_offset();
                                
                                _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_id)
                                    .set_index(is_struct(_placement_index) ? smart_value(_placement_index) : _placement_index)
                                    .set_index_offset(is_struct(_placement_index_offset) ? smart_value(_placement_index_offset) : _placement_index_offset);
                                
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
                            
                            // OPTIMIZATION: Inline smart_value check
                            var _placement_index = _data.get_placement_index();
                            var _placement_index_offset = _data.get_placement_index_offset();
                            
                            _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_index(is_struct(_placement_index) ? smart_value(_placement_index) : _placement_index)
                                .set_index_offset(is_struct(_placement_index_offset) ? smart_value(_placement_index_offset) : _placement_index_offset);
                            
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
                            
                            // OPTIMIZATION: Inline smart_value check
                            var _placement_index = _data.get_placement_index();
                            var _placement_index_offset = _data.get_placement_index_offset();
                            
                            _chunk.chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_index(is_struct(_placement_index) ? smart_value(_placement_index) : _placement_index)
                                .set_index_offset(is_struct(_placement_index_offset) ? smart_value(_placement_index_offset) : _placement_index_offset);
                            
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
                            
                            // OPTIMIZATION: Inline smart_value check
                            var _placement_index = _data.get_placement_index();
                            var _placement_index_offset = _data.get_placement_index_offset();
                            
                            _chunk.chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_id)
                                .set_xscale(((_data.can_flip_on_x()) && (_xorshift & (1 << (CHUNK_SIZE + j)))) ? -1 : 1)
                                .set_index(is_struct(_placement_index) ? smart_value(_placement_index) : _placement_index)
                                .set_index_offset(is_struct(_placement_index_offset) ? smart_value(_placement_index_offset) : _placement_index_offset);
                            
                            _chunk.chunk_display |= 1 << _z;
                        }
                    }
                }
            }
        }
        
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    // =========================================================================
    // Calculate occlusion flags for each tile position
    // A tile is occluded if all layers above it (up to DEFAULT) are opaque/solid
    // =========================================================================
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _occluded = 0;
            var _has_opaque_above = false;
            
            // Iterate from top (DEFAULT) down to bottom (WALL)
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
                    if (_data != undefined && !_data.is_transparent() && _data.has_type(ITEM_TYPE_BIT.SOLID))
                    {
                        _has_opaque_above = true;
                    }
                }
            }
            
            _chunk.chunk_occluded[@ tile_index_xy(i, j)] = _occluded;
        }
    }
}