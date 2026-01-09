/// @function chunk_generate(_chunk)
/// @desc Generate terrain for a _chunk.chunk
/// @param {Struct.Chunk} _chunk The _chunk.chunk to generate
function chunk_generate(_chunk)
{
    static __cave_bit = array_create(CHUNK_SIZE);
    static __density_array = array_create(CHUNK_SIZE * CHUNK_SIZE);
    static __wall_density_array = array_create(CHUNK_SIZE * CHUNK_SIZE); // For overhangs
    static __surface_height = array_create(CHUNK_SIZE);
    static __skip_z_array = array_create(CHUNK_SIZE * CHUNK_SIZE);
    
    // Reset arrays
    for (var i = 0; i < CHUNK_SIZE * CHUNK_SIZE; ++i) 
    {
        __skip_z_array[@ i] = 0;
        __density_array[@ i] = -1;
        __wall_density_array[@ i] = -1;
    }
    
    var _surface_height_max = 999999;
    
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
    
    var _cave_noise_scale = _world_data.get_cave_noise_scale();
    var _cave_system = _world_data.get_cave_system();
    var _cave_system_length = _world_data.get_cave_system_length();
    var _cave_depth_smoothing = _world_data.get_cave_depth_smoothing();
    
    var _cave_breach_depth = _world_data.get_cave_breach_depth();
    var _cave_breach_noise_scale_x = _world_data.get_cave_breach_noise_scale_x();
    var _cave_breach_noise_scale_y = _world_data.get_cave_breach_noise_scale_y();
    var _cave_breach_noise_offset_y = _world_data.get_cave_breach_noise_offset_y();
    var _cave_breach_noise_range = _world_data.get_cave_breach_noise_range();
    var _cave_breach_noise_octaves = _world_data.get_cave_breach_noise_octaves();
    var _cave_breach_threshold = _world_data.get_cave_breach_threshold();
    
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
    
    var _cave_biome_map = _world_data.get_cave_biome_map();
    var _cave_biome_depth_zones = _world_data.get_cave_biome_depth_zones();
    var _cave_biome_depth_zones_length = _world_data.get_cave_biome_depth_zones_length();
    
    var _sky_biome_enabled = _world_data.is_sky_biome_enabled();
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    var _sky_biome_id = _sky_biome_enabled ? _world_data.get_sky_biome_id() : undefined;
    
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
    
    var _aquifers = _world_data.get_aquifers();
    var _aquifers_length = _world_data.get_aquifers_length();
    
    var _bedrock_depth = _world_data.get_bedrock_depth();
    var _bedrock_noise_scale = _world_data.get_bedrock_noise_scale();
    
    var _tile_variation_noise_scale = _world_data.get_tile_variation_noise_scale();
    var _biome_blend_range = _world_data.get_biome_blend_range();
    var _biome_blend_noise_scale = _world_data.get_biome_blend_noise_scale();
    
    var _default_caves = _world_data.get_cave_biome_default();
    var _default_caves_length = array_length(_default_caves);
    
    var _biome_data_struct = global.biome_data;
    
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
            if (_world_data.is_sky_biome_enabled() && worldgen_get_sky_island(_x, _y, _seed, _world_data, _surface_height)) return false;

            if (_depth_from_surface > _cave_breach_depth)
            {
                var _breach_noise = open_simplex_noise(_x * _cave_breach_noise_scale_x, _surface_height * _cave_breach_noise_scale_y + _cave_breach_noise_offset_y, _cave_breach_noise_range, _cave_breach_noise_octaves);
                if (_breach_noise > _cave_breach_threshold)
                {
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
    }
    
    static __get_cave_heat_inline = function(_x, _y, _enabled, _scale_x, _scale_y, _range, _octaves)
    {
        if (!_enabled) return 0;
        return round(open_simplex_noise(_x * _scale_x, _y * _scale_y, _range, _octaves));
    }
    
    static __get_cave_humidity_inline = function(_x, _y, _enabled, _scale_x, _scale_y, _offset_y, _range, _octaves)
    {
        if (!_enabled) return 0;
        return round(open_simplex_noise(_x * _scale_x, _y * _scale_y + _offset_y, _range, _octaves));
    }
    
    static __get_heat_inline = function(_x, _y, _noise_scale, _offset, _range, _octaves, _spline_x, _spline_y)
    {
        var __noise = open_simplex_noise(_x * _noise_scale, _offset, _range, _octaves);
        var __gradient = 0;
        if (_spline_x != undefined) __gradient += spline_evaluate(_spline_x, _x);
        if (_spline_y != undefined) __gradient += spline_evaluate(_spline_y, _y);
        return clamp(round(__noise + (__gradient * _range)), 0, _range);
    }
    
    static __get_humidity_inline = function(_x, _y, _noise_scale, _offset, _range, _octaves, _spline_x, _spline_y)
    {
        var __noise = open_simplex_noise(_x * _noise_scale, _offset, _range, _octaves);
        var __gradient = 0;
        if (_spline_x != undefined) __gradient += spline_evaluate(_spline_x, _x);
        if (_spline_y != undefined) __gradient += spline_evaluate(_spline_y, _y);
        return clamp(round(__noise + (__gradient * _range)), 0, _range);
    }
    
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        var _world_x = _chunk.chunk_xstart + i;
        
        var _surface_height = worldgen_get_surface_height(_world_x, _world_seed, _world_data);
        
        if (_structure_rectangle_length > 0)
        {
            _surface_height = worldgen_apply_structure_terrain_modifier(_world_x, _surface_height, __structure_array, _structure_data);
        }
        
        var _cave_start = worldgen_get_cave_start(_world_x, _world_seed, _world_data);
        
        __surface_height[@ i] = _surface_height;
        
        _surface_height_max = min(_surface_height_max, _surface_height);
        
        
        var _cave_bit = 0; // Keeping this for now if needed for Foliage logic (is_cave?), but better to rely on density
        
        // --- PRE-CALCULATE DENSITY for this column ---
        for (var j = 0; j < CHUNK_SIZE + 2; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j - 1;
            
            // Calculate detailed density (Solid)
            var _dens = global.terrain_generator.get_density_detailed(_world_x, _world_y, 0, _world_data, _world_seed);
            
            // Calculate wall density (Overhang check)
            var _wall_offset = _world_data.get_wall_noise_offset() ?? 0.15;
            var _dens_wall = global.terrain_generator.get_density_detailed(_world_x, _world_y, _wall_offset, _world_data, _world_seed);
            
            // Store in array (clamped to chunk bounds)
            if (j > 0 && j <= CHUNK_SIZE)
            {
                var _idx = i + ((j - 1) * CHUNK_SIZE);
                __density_array[@ _idx] = _dens;
                __wall_density_array[@ _idx] = _dens_wall;
            }
            
            // Legacy cave bit for foliage check (approximate: if density > 0, it's solid)
            // But wait, foliage check needs to know if ABOVE is air.
            // We can just check density of above in the main loop.
            // __cave_bit is not needed if we check density.
        }
        
        // __cave_bit[@ i] = _cave_bit; // Disabled legacy cave bit calculation logic
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
    
    var _in_sky_zone = (_chunk.chunk_ystart <= _sky_threshold) && _sky_biome_enabled;
    var _overhang_enabled = (_world_data.get_cave_overhang_threshold() != undefined);
    
    // Don't skip if: structures exist, in sky zone, or overhangs are enabled
    if (_structure_rectangle_length <= 0) && (_surface_height_max > _chunk.chunk_ystart + CHUNK_SIZE - 1) && (!_in_sky_zone) && (!_overhang_enabled) exit;
    
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
            
            if (_sx_start >= _sx_end || _sy_start >= _sy_end) continue;
            
            structure_generate(_inst, _world_seed, _item_data, _structure_data, _natural_structure_data);
            
            var _data = _inst.data;
            
            for (var _sy = _sy_start; _sy < _sy_end; ++_sy)
            {
                var _chunk_y = _rel_y + _sy;
                
                for (var _sx = _sx_start; _sx < _sx_end; ++_sx)
                {
                    var _chunk_x = _rel_x + _sx;;
                    
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
        
        // 1. Resolve Region
        var _region = global.region_generator.get_region(_world_x, 0, 0, _world_seed);
        
        // 2. Resolve Surface Height (use old working worldgen function)
        var _surface_height = __surface_height[i];
        var _cave_start = worldgen_get_cave_start(_world_x, _world_seed, _world_data);
        
        // Get Surface Biome from Region
        var _surface_biome_id = _region.get_surface_biome_id();
        var _surface_biome_data = global.biome_data[$ _surface_biome_id];
        var _sea_level = 450; // default sea level, effectively overridden by liquid placement logic
        
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _world_y = _chunk.chunk_ystart + j;
            var _inst_y = _world_y * TILE_SIZE;
            var _chunk_index = i + (j * CHUNK_SIZE);
            var _skip_z = __skip_z_array[_chunk_index];
            
            // Retrieve pre-calculated density
            var _density = __density_array[_chunk_index];
            var _density_wall = __wall_density_array[_chunk_index];
            
            var _is_solid = (_density > 0);
            var _is_wall = (_density_wall > 0);
            
            // Check density above (for surface/foliage detection)
            // If j=0, we need to check y-1 density.
            // Since we only cached chunk size, we might need to calc one above/below or use cache if implemented (we didn't cache boundary).
            // Optimization: Just calculate it if needed or edge case.
            // Actually, we can check _chunk_ystart + j - 1.
            var _density_above = -1;
            if (j > 0) 
            {
                 _density_above = __density_array[i + ((j - 1) * CHUNK_SIZE)];
            }
            else
            {
                // Retrieve from worldgen for boundary check
                 _density_above = global.terrain_generator.get_density_detailed(_world_x, _world_y - 1, 0, _world_data, _world_seed);
            }
            var _is_solid_above = (_density_above > 0);
            var _is_air_above = !_is_solid_above;
            
            // Use this for "cave" logic: if we are solid, we are NOT a cave (in the old sense of "air").
            // Old code: _is_cave = bit set means AIR (carved).
            // New code: _density > 0 means SOLID.
            
            var _is_cave = !_is_solid; // "Cave" implies open space underground/sky
            
            // Skip if above surface and not solid (Sky Air)
            // BUT: overhangs logic means we might have solids above surface!
            // Condition: if density <= 0 AND not in sky zone...
            // Actually, just trust density. If density <= 0, it's air.
            // Wait, we need to skip trivial air to save performance?
            // If density <= 0 and we are high up...
            // But we must check WALLS.
            
            // Optim: If not solid and not wall -> EMPTY.
            if (!_is_solid && !_is_wall) continue;
            
            // Get cave biome if underground (Logic depends on depth > 8 below surface height estimate)
            // Surface Height estimate from 2D generator is still useful for "Biome Depth".
            var _depth_from_surface = _world_y - _surface_height;
            var _cave_biome = undefined;
            if (_depth_from_surface >= 8)
            {
                _cave_biome = worldgen_get_biome_cave(_world_x, _world_y, _surface_height, _world_seed);
            }
            
            // --- BASE TILE ---
            if !(_skip_z & (1 << CHUNK_DEPTH_DEFAULT))
            {
                if (_is_solid)
                {
                    // Pass TRUE to bypass density check since we already know it is solid
                    var _tile_id = worldgen_get_tile_base(_world_x, _world_y, _surface_biome_id, _cave_biome, _surface_height, _is_air_above, _world_seed, true);
                    
                    if (_tile_id != TILE_EMPTY)
                    {
                        var _data = _item_data[$ _tile_id];
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                            var _idx = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                            _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_id).set_index(_idx);
                            _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                            
                            if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                            {
                                _chunk.chunk_covered[@ i] |= 1 << j;
                            }
                        }
                    }
                }
                else
                {
                    // --- AQUIFER LOGIC ---
                    // Aquifers (water/lava) filling caves (Empty Air)
                    // Only check aquifers if not solid
                    var _aquifer = worldgen_get_aquifer(_world_x, _world_y, _surface_height, _world_seed, _world_data);
                    
                    if (_aquifer != undefined)
                    {
                        if (_aquifer.is_edge)
                        {
                            // Place solid edge block (stone around water, obsidite around lava, etc.)
                            var _edge_tile_id = _aquifer.edge_tile;
                            var _data = _item_data[$ _edge_tile_id];
                            if (_data != undefined)
                            {
                                ++_chunk.chunk_count[@ CHUNK_DEPTH_DEFAULT];
                                var _idx = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                                _chunk.chunk[@ (CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_edge_tile_id).set_index(_idx);
                                _chunk.chunk_display |= 1 << CHUNK_DEPTH_DEFAULT;
                                
                                if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                                {
                                    _chunk.chunk_covered[@ i] |= 1 << j;
                                }
                            }
                        }
                        else if (_aquifer.type != undefined)
                        {
                            // Place liquid tile in CHUNK_DEPTH_LIQUID layer
                            var _liquid_tile_id = _aquifer.type;
                            var _data = _item_data[$ _liquid_tile_id];
                            if (_data != undefined)
                            {
                                ++_chunk.chunk_count[@ CHUNK_DEPTH_LIQUID];
                                _chunk.chunk[@ (CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_liquid_tile_id).set_component("level", _aquifer.fill_level);
                                _chunk.chunk_display |= 1 << CHUNK_DEPTH_LIQUID;
                            }
                        }
                    }
                }
            }
            
            // --- WALLS ---
            if !(_skip_z & (1 << CHUNK_DEPTH_WALL))
            {
                // Check if we need walls
                // Condition: If Density Wall > 0 OR Density Solid > 0
                if (_is_wall || _is_solid)
                {
                    // Pass TRUE to bypass density check
                    var _wall_id = worldgen_get_tile_wall(_world_x, _world_y, _surface_biome_id, _cave_biome, _surface_height, _world_seed, true);
                    
                if (_wall_id != TILE_EMPTY)
                {
                    var _data = _item_data[$ _wall_id];
                    if (_data != undefined)
                    {
                        ++_chunk.chunk_count[@ CHUNK_DEPTH_WALL];
                        var _idx = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                        _chunk.chunk[@ (CHUNK_DEPTH_WALL << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_wall_id).set_index(_idx);
                        _chunk.chunk_display |= 1 << CHUNK_DEPTH_WALL;
                        
                        if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE)) && (!_data.is_transparent())
                        {
                            _chunk.chunk_covered[@ i] |= 1 << j;
                        }
                    }
                }
            }
        }
            
            // Foliage / Decorations (when above solid ground)
            // Check if current is Air and Below is Solid
            
            // Check density below (Optimization: use pre-calc array if possible)
            var _density_below = -1;
            if (j < CHUNK_SIZE - 1)
            {
                 _density_below = __density_array[i + ((j + 1) * CHUNK_SIZE)];
            }
            else
            {
                 _density_below = global.terrain_generator.get_density_detailed(_world_x, _world_y + 1, 0, _world_data, _world_seed);
            }
            var _is_solid_below = (_density_below > 0);
            
            if (!_is_solid && _is_solid_below) // Air above solid = floor for foliage
            {
                var _z = ((xorshift(_world_seed ^ (_world_x * 457)) & (1 << j)) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
                if !(_skip_z & (1 << _z)) 
                {
                    // Get the base tile for foliage placement check
                    var _tile_base = worldgen_get_tile_base(_world_x, _world_y + 1, _surface_biome_id, _cave_biome, _surface_height, true, _world_seed);
                    
                    var _tile_foliage = worldgen_get_tile_foliage(_world_x, _world_y, _surface_biome_id, _cave_biome, _tile_base, _surface_height, _world_seed);
                    
                    if (_tile_foliage != TILE_EMPTY)
                    {
                        var _data = _item_data[$ _tile_foliage];
                        if (_data != undefined)
                        {
                            ++_chunk.chunk_count[@ _z];
                            var _flip = ((_data.can_flip_on_x()) && (xorshift(_world_seed ^ (_world_x * 997)) & 1)) ? -1 : 1;
                            
                            var _idx = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
                            _chunk.chunk[@ (_z << (CHUNK_SIZE_BIT * 2)) | (j << CHUNK_SIZE_BIT) | i] = new Tile(_tile_foliage).set_index(_idx).set_xscale(_flip);
                            _chunk.chunk_display |= 1 << _z;
                        }
                    }
                }
            }
        }
        
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    // Occlusion pass
    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            var _occluded = 0;
            var _has_opaque_above = false;
            
            for (var _z = CHUNK_DEPTH_DEFAULT; _z >= CHUNK_DEPTH_WALL; --_z)
            {
                if (_has_opaque_above) _occluded |= (1 << _z);
                
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