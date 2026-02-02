#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 8)

global.worldgen_structure = ds_map_create();

function control_structure(_x, _y)
{
    var _biome_data = global.biome_data;
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _structure_data = global.structure_data;
    
    var _world_seed = global.world_save_data.seed;
    
    var _tile_xstart = _x * CHUNK_SIZE;
    var _tile_ystart = _y * CHUNK_SIZE;
    
    // Iterate over chunks in the vicinity (WORLDGEN_STRUCTURE_OFFSET is 128 tiles = 8 chunks)
    var _chunk_range = WORLDGEN_STRUCTURE_OFFSET >> CHUNK_SIZE_BIT;
    
    for (var _ci = _x - _chunk_range; _ci <= _x + _chunk_range; ++_ci)
    {
        var _ds = global.worldgen_structure[? _ci];
        if (_ds == undefined)
        {
            _ds = ds_map_create();
            global.worldgen_structure[? _ci] = _ds;
        }
        
        for (var _cj = _y - _chunk_range; _cj <= _y + _chunk_range; ++_cj)
        {
            if (ds_map_exists(_ds, _cj)) continue;
            _ds[? _cj] = true;
            
            // Now iterate every tile in this chunk
            for (var _ti = 0; _ti < CHUNK_SIZE; ++_ti)
            {
                var i = (_ci << CHUNK_SIZE_BIT) + _ti;
                
                // HOIST: Calculate column parameters ONCE
                var _surface_height = worldgen_get_surface_height(i, _world_seed, _world_data);
                var _heat = worldgen_get_heat(i, 0, _world_seed, _world_data);
                var _humidity = worldgen_get_humidity(i, 0, _world_seed, _world_data);
                
                var _queue = 0;
                var _queue_valid = false;
                
                for (var _tj = 0; _tj < CHUNK_SIZE; ++_tj)
                {
                    var j = (_cj << CHUNK_SIZE_BIT) + _tj;
                    
                    // Maintain a small sliding window for cave/air check
                    // OPTIMIZATION: Pass pre-calculated _surface_height
                    if (!_queue_valid)
                    {
                        _queue =
                            (!worldgen_is_solid(i, j + 1, _world_seed, undefined, _surface_height) << 0) |
                            (!worldgen_is_solid(i, j + 0, _world_seed, undefined, _surface_height) << 1) |
                            (!worldgen_is_solid(i, j - 1, _world_seed, undefined, _surface_height) << 2);
                        _queue_valid = true;
                    }
                    else
                    {
                        _queue = ((_queue & 0b011) << 1) | (!worldgen_is_solid(i, j + 1, _world_seed, undefined, _surface_height) & 0b001);
                    }
                    
                    // OPTIMIZATION: Pass pre-calculated column params to bg_get_biome
                    var _biome_id = bg_get_biome(i, j, _surface_height, _heat, _humidity);
                    var _data = _biome_data[$ _biome_id];
                    
                    if (_data == undefined)
                    {
                        _data = _biome_data[$ "phantasia:surface/forest"];
                        if (_data == undefined) continue;
                    }
                    
                    var _length = _data.get_structure_length();
                    var _chance_seed = (_world_seed & 0xffff) ^ (abs(_world_seed) >> 16) ^ (i * 1_497.931) ^ (j * 693.571);
                    
                    for (var l = 0; l < _length; ++l)
                    {
                        var _structure = _data.get_structure(l);
                        if (!chance_seeded(_structure.chance, _chance_seed ^ ((l + 1) * 341.113))) continue;
                        
                        var _range = _structure[$ "range"];
                        if (_range != undefined)
                        {
                            var _min = _range[$ "min"];
                            if (_min != undefined) && (j < _min) continue;
                            
                            var _max = _range[$ "max"];
                            if (_max != undefined) && (j >= _max) continue;
                        }
                        
                        var _id = _structure.id;
                        if (is_array(_id))
                        {
                            var _id_length = array_length(_id);
                            var _generate = true;
                            
                            for (var m = 0; m < _id_length; ++m)
                            {
                                var _id2 = _id[m];
                                var _placement_type = _structure_data[$ _id2].get_placement_type();
                                
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
                                    // OPTIMIZATION: Pass surface height to structure_valid (if it supported it, but it doesn't yet)
                                    if (!structure_valid(i * TILE_SIZE, j * TILE_SIZE, _id[m], _world_seed)) { _generate = false; break; }
                                }
                            }
                            
                            if (_generate)
                            {
                                for (var m = 0; m < _id_length; ++m)
                                {
                                    structure_create(i * TILE_SIZE, j * TILE_SIZE, _id[m], _world_seed);
                                }
                            }
                        }
                        else
                        {
                            var _placement_type = _structure_data[$ _id].get_placement_type();
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
                            
                            if (_valid) structure_create(i * TILE_SIZE, j * TILE_SIZE, _id, _world_seed);
                        }
                    }
                }
            }
        }
    }
}