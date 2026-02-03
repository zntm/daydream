#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 1)

global.worldgen_structure = ds_map_create();

/// @function control_structure(_chunk_x, _chunk_y)
/// @desc Evaluate structure spawn points for chunks near the given chunk coordinates.
///       Structures are added to global.structure_pool for later application by chunk_generate.
/// @param {real} _chunk_x Chunk X coordinate (in chunk units, not tiles)
/// @param {real} _chunk_y Chunk Y coordinate (in chunk units, not tiles)
function control_structure(_chunk_x, _chunk_y)
{
    var _biome_data = global.biome_data;
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _structure_data = global.structure_data;
    var _world_seed = global.world_save_data.seed;
    
    // Only scan a 3x3 chunk neighborhood (reduced from 17x17)
    // This is sufficient for structures up to 16 tiles (1 chunk) in size
    var _chunk_range = WORLDGEN_STRUCTURE_OFFSET >> CHUNK_SIZE_BIT;
    
    for (var _ci = _chunk_x - _chunk_range; _ci <= _chunk_x + _chunk_range; ++_ci)
    {
        var _ds = global.worldgen_structure[? _ci];
        if (_ds == undefined)
        {
            _ds = ds_map_create();
            global.worldgen_structure[? _ci] = _ds;
        }
        
        for (var _cj = _chunk_y - _chunk_range; _cj <= _chunk_y + _chunk_range; ++_cj)
        {
            // Skip already-processed chunks
            if (ds_map_exists(_ds, _cj)) continue;
            _ds[? _cj] = true;
            
            // Calculate tile ranges for this chunk
            var _tile_xstart = _ci << CHUNK_SIZE_BIT;
            var _tile_ystart = _cj << CHUNK_SIZE_BIT;
            var _tile_yend = _tile_ystart + CHUNK_SIZE - 1;
            
            // OPTIMIZATION: Pre-calculate surface heights for all 16 columns
            // This avoids recalculating per-tile
            static __col_surface = array_create(CHUNK_SIZE);
            static __col_heat = array_create(CHUNK_SIZE);
            static __col_humidity = array_create(CHUNK_SIZE);
            static __col_solid_mask = array_create(CHUNK_SIZE); // Bitmask: bit j = 1 if tile j is solid
            
            var _min_surface = 999999;
            var _max_surface = -999999;
            
            for (var _ti = 0; _ti < CHUNK_SIZE; ++_ti)
            {
                var _world_x = _tile_xstart + _ti;
                var _surface = worldgen_get_surface_height(_world_x, _world_seed, _world_data);
                __col_surface[@ _ti] = _surface;
                __col_heat[@ _ti] = worldgen_get_heat(_world_x, 0, _world_seed, _world_data);
                __col_humidity[@ _ti] = worldgen_get_humidity(_world_x, 0, _world_seed, _world_data);
                
                _min_surface = min(_min_surface, _surface);
                _max_surface = max(_max_surface, _surface);
                
                // Pre-compute solid mask for this column
                // Only compute for tiles that could be near surface (±CHUNK_SIZE from surface)
                var _mask = 0;
                var _scan_start = max(0, _surface - _tile_ystart - CHUNK_SIZE);
                var _scan_end = min(CHUNK_SIZE - 1, _surface - _tile_ystart + CHUNK_SIZE);
                
                for (var _tj = _scan_start; _tj <= _scan_end; ++_tj)
                {
                    var _world_y = _tile_ystart + _tj;
                    if (worldgen_is_solid(_world_x, _world_y, _world_seed, undefined, _surface))
                    {
                        _mask |= (1 << _tj);
                    }
                }
                __col_solid_mask[@ _ti] = _mask;
            }
            
            // EARLY EXIT: If the entire chunk is above or below the surface band, skip it
            // Structures only spawn near the surface (within ~16 tiles)
            if (_tile_yend < _min_surface - CHUNK_SIZE) continue; // Chunk is entirely in sky
            if (_tile_ystart > _max_surface + CHUNK_SIZE) continue; // Chunk is deep underground
            
            // Iterate tiles in this chunk
            for (var _ti = 0; _ti < CHUNK_SIZE; ++_ti)
            {
                var _world_x = _tile_xstart + _ti;
                var _surface_height = __col_surface[_ti];
                var _heat = __col_heat[_ti];
                var _humidity = __col_humidity[_ti];
                var _solid_mask = __col_solid_mask[_ti];
                
                for (var _tj = 0; _tj < CHUNK_SIZE; ++_tj)
                {
                    var _world_y = _tile_ystart + _tj;
                    
                    // EARLY EXIT: Skip tiles far from surface (no surface structures here)
                    var _dist_from_surface = _world_y - _surface_height;
                    if (_dist_from_surface < -CHUNK_SIZE || _dist_from_surface > CHUNK_SIZE) continue;
                    
                    // Get air/solid state from bitmask (current, below, above)
                    var _is_solid_current = (_solid_mask >> _tj) & 1;
                    var _is_solid_below = (_tj > 0) ? ((_solid_mask >> (_tj - 1)) & 1) : 1;
                    var _is_solid_above = (_tj < CHUNK_SIZE - 1) ? ((_solid_mask >> (_tj + 1)) & 1) : 0;
                    
                    // Build queue bits: bit0=below, bit1=current, bit2=above
                    // air = 1, solid = 0 for compatibility with existing checks
                    var _queue = ((!_is_solid_below) << 0) | ((!_is_solid_current) << 1) | ((!_is_solid_above) << 2);
                    
                    var _biome_id = bg_get_biome(_world_x, _world_y, _surface_height, _heat, _humidity);
                    var _data = _biome_data[$ _biome_id];
                    
                    if (_data == undefined)
                    {
                        _data = _biome_data[$ "phantasia:surface/forest"];
                        if (_data == undefined) continue;
                    }
                    
                    var _length = _data.get_structure_length();
                    if (_length == 0) continue;
                    
                    var _chance_seed = (_world_seed & 0xffff) ^ (abs(_world_seed) >> 16) ^ (_world_x * 1_497.931) ^ (_world_y * 693.571);
                    
                    for (var l = 0; l < _length; ++l)
                    {
                        var _structure = _data.get_structure(l);
                        if (!chance_seeded(_structure.chance, _chance_seed ^ ((l + 1) * 341.113))) continue;
                        
                        var _range = _structure[$ "range"];
                        if (_range != undefined)
                        {
                            var _min = _range[$ "min"];
                            if (_min != undefined) && (_world_y < _min) continue;
                            
                            var _max = _range[$ "max"];
                            if (_max != undefined) && (_world_y >= _max) continue;
                        }
                        
                        var _id = _structure.id;
                        if (is_array(_id))
                        {
                            var _id_length = array_length(_id);
                            var _generate = true;
                            
                            for (var m = 0; m < _id_length; ++m)
                            {
                                var _id2 = _id[m];
                                var _struct_data_ptr = _structure_data[$ _id2];
                                if (_struct_data_ptr == undefined) { _generate = false; break; }
                                
                                var _placement_type = _struct_data_ptr.get_placement_type();
                                
                                // Floor: Current is AIR (bit 1), Below is SOLID (bit 0 = 0)
                                if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                                {
                                    if (!(_queue & 0b010) || (_queue & 0b001)) { _generate = false; break; }
                                }
                                // Ceiling: Current is AIR (bit 1), Above is SOLID (bit 2 = 0)
                                else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                                {
                                    if (!(_queue & 0b010) || (_queue & 0b100)) { _generate = false; break; }
                                }
                                // Inside: Current is SOLID (bit 1 = 0)
                                else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE)
                                {
                                    if (_queue & 0b010) { _generate = false; break; }
                                }
                            }
                            
                            if (_generate)
                            {
                                for (var m = 0; m < _id_length; ++m)
                                {
                                    if (!structure_valid(_world_x * TILE_SIZE, _world_y * TILE_SIZE, _id[m], _world_seed)) { _generate = false; break; }
                                }
                            }
                            
                            if (_generate)
                            {
                                for (var m = 0; m < _id_length; ++m)
                                {
                                    structure_create(_world_x * TILE_SIZE, _world_y * TILE_SIZE, _id[m], _world_seed);
                                }
                            }
                        }
                        else
                        {
                            var _struct_data_ptr = _structure_data[$ _id];
                            if (_struct_data_ptr != undefined)
                            {
                                var _placement_type = _struct_data_ptr.get_placement_type();
                                var _valid = false;
                                
                                if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                                {
                                    if ((_queue & 0b010) && !(_queue & 0b001)) _valid = true;
                                }
                                else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                                {
                                    if ((_queue & 0b010) && !(_queue & 0b100)) _valid = true;
                                }
                                else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE)
                                {
                                    if (!(_queue & 0b010)) _valid = true;
                                }
                                
                                if (_valid) structure_create(_world_x * TILE_SIZE, _world_y * TILE_SIZE, _id, _world_seed);
                            }
                        }
                    }
                }
            }
        }
    }
}
