#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 8)

global.worldgen_structure = ds_map_create();

function control_structure(_x, _y)
{
    var _biome_data = global.biome_data;
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _structure_data = global.structure_data;
    
    var _world_seed = global.world_save_data.seed;
    
    for (var i = _x - WORLDGEN_STRUCTURE_OFFSET; i <= _x + WORLDGEN_STRUCTURE_OFFSET; ++i)
    {
        var _ds = global.worldgen_structure[? i];
        if (_ds == undefined)
        {
            _ds = ds_map_create();
            global.worldgen_structure[? i] = _ds;
        }
        
        var _surface_height = undefined;
        var _cave_start = undefined;
        
        var _ystart = _y - WORLDGEN_STRUCTURE_OFFSET;
        var _yend   = _y + WORLDGEN_STRUCTURE_OFFSET;
        var _queue = 0;
        var _queue_valid = false;
        
        for (var j = _ystart; j <= _yend; ++j)
        {
            if (ds_map_exists(_ds, j))
            {
                // Skip already processed blocks
                j = (((j >> CHUNK_SIZE_BIT) + 1) << CHUNK_SIZE_BIT) - 1;
                _queue_valid = false; // Must re-initialize after skip
                continue;
            }

            // Calculate surface height and cave start only once per column if needed
            if (_surface_height == undefined) _surface_height = worldgen_get_surface_height(i, _world_seed, _world_data);
            if (_cave_start == undefined) _cave_start = worldgen_get_cave_start(i, _world_seed, _world_data);

            // Maintain a small sliding window for cave noise
            if (!_queue_valid)
            {
                _queue =
                    (worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data) << 0) |
                    (worldgen_get_cave(i, j + 0, _surface_height, _cave_start, _world_seed, _world_data) << 1) |
                    (worldgen_get_cave(i, j - 1, _surface_height, _cave_start, _world_seed, _world_data) << 2);
                _queue_valid = true;
            }
            else
            {
                // Shift and add next
                _queue = ((_queue & 0b011) << 1) | worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data);
            }
            
            global.worldgen_structure[? i][? j] = true;
            
            // If current tile (bit 1) is not cave
            if (_queue & 0b010) continue;
            
            var _heat = worldgen_get_heat(i, j, _world_seed, _world_data);
            var _humidity = worldgen_get_humidity(i, j, _world_seed, _world_data);
            var _data = _biome_data[$ bg_get_biome(i, j, _surface_height, _heat, _humidity)];
            
            if (_data == undefined) continue;
            
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
                    var _struct_seed = _chance_seed ^ (_id_length * 521.123);
                    
                    for (var m = 0; m < _id_length; ++m)
                    {
                        var _id2 = _id[m];
                        var _struct_data_ptr = _structure_data[$ _id2];
                        if (_struct_data_ptr == undefined) { _generate = false; break; }
                        
                        var _placement_type = _struct_data_ptr.get_placement_type();
                        
                        // Placement Type Check
                        if ((_queue & 0b100) && !(_queue & 0b001)) // Floor check: solid above, air below
                        {
                            if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR) continue;
                        }
                        else if (_queue & 0b001) // Ceiling check: air above
                        {
                            if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING) continue;
                        }
                        else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE) continue;
                        
                        _generate = false;
                        break;
                    }
                    
                    if (_generate)
                    {
                        for (var m = 0; m < _id_length; ++m)
                        {
                            var _id2 = _id[m];
                            random_set_seed(_struct_seed + m * 100);
                            if (!structure_valid(i * TILE_SIZE, j * TILE_SIZE, _id2, _world_seed))
                            {
                                _generate = false;
                                break;
                            }
                        }
                    }
                    
                    if (_generate)
                    {
                        for (var m = 0; m < _id_length; ++m)
                        {
                            var _id2 = _id[m];
                            random_set_seed(_struct_seed + m * 100);
                            structure_create(i * TILE_SIZE, j * TILE_SIZE, _id2, _world_seed);
                        }
                    }
                }
                else
                {
                    var _struct_data_ptr = _structure_data[$ _id];
                    if (_struct_data_ptr == undefined) continue;
                    
                    var _placement_type = _struct_data_ptr.get_placement_type();
                    
                    if ((_queue & 0b100) && !(_queue & 0b001))
                    {
                        if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                        {
                            structure_create(i * TILE_SIZE, j * TILE_SIZE, _id, _world_seed);
                        }
                    }
                    else if (_queue & 0b001)
                    {
                        if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                        {
                            structure_create(i * TILE_SIZE, j * TILE_SIZE, _id, _world_seed);
                        }
                    }
                    else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE)
                    {
                        structure_create(i * TILE_SIZE, j * TILE_SIZE, _id, _world_seed);
                    }
                }
            }
        }
    }
}
