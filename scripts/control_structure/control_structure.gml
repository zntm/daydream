#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 8)

global.worldgen_structure = ds_map_create();

function control_structure(_x, _y)
{
    var _biome_data = global.biome_data;
    var _world_data = global.world_data[$ global.current_world.dimension];
    var _structure_data = global.structure_data;
    
    var _world_seed = global.current_world.seed;
    
    var _cx_start = floor((_x - WORLDGEN_STRUCTURE_OFFSET) / CHUNK_SIZE);
    var _cx_end   = floor((_x + WORLDGEN_STRUCTURE_OFFSET) / CHUNK_SIZE);
    var _cy_start = floor((_y - WORLDGEN_STRUCTURE_OFFSET) / CHUNK_SIZE);
    var _cy_end   = floor((_y + WORLDGEN_STRUCTURE_OFFSET) / CHUNK_SIZE);
    
    for (var _cx = _cx_start; _cx <= _cx_end; ++_cx)
    {
        var _ds = global.worldgen_structure[? _cx];
        
        if (_ds == undefined)
        {
            _ds = ds_map_create();
            
            global.worldgen_structure[? _cx] = _ds;
        }
        
        var _xstart = _cx * CHUNK_SIZE;
        var _xend   = _xstart + CHUNK_SIZE;
        
        var _process_mask = 0;
        
        for (var _cy = _cy_start; _cy <= _cy_end; ++_cy)
        {
            /* skip already processed chunks */
            if (ds_map_exists(_ds, _cy)) continue;
            
            global.worldgen_structure[? _cx][? _cy] = true;
            
            _process_mask |= 1 << (_cy - _cy_start);
        }
        
        if (!_process_mask) continue;
        
        for (var i = _xstart; i < _xend; ++i)
        {
            var _blend_data = _world_data.get_region_blend_data(i, 0, _world_seed);
            
            var _surface_height = worldgen_get_surface_height(i, _world_seed, _world_data, _blend_data);
            var _cave_start = worldgen_get_cave_start(i, _world_seed, _world_data);
            
            var _h_left = worldgen_get_surface_height(i - 1, _world_seed, _world_data);
            var _h_right = worldgen_get_surface_height(i + 1, _world_seed, _world_data);
            
            var _slope = max(abs(_surface_height - _h_left), abs(_h_right - _surface_height));
            
            var _biome_id = worldgen_get_biome_surface(i, _surface_height, _surface_height, _world_seed, _world_data, _slope, _blend_data);
            var _data = _biome_data[$ _biome_id];
            
            var _cave_below = worldgen_get_cave(i, _surface_height + 2, _surface_height, _cave_start, _world_seed, _world_data);
            
            for (var _cy = _cy_start; _cy <= _cy_end; ++_cy)
            {
                if !(_process_mask & (1 << (_cy - _cy_start))) continue;
                
                var _ystart = _cy * CHUNK_SIZE;
                var _yend   = _ystart + CHUNK_SIZE;
                
                var _queue = 0;
                var _queue_valid = false;
                
                for (var j = _ystart; j < _yend; ++j)
                {
                    if (!_queue_valid)
                    {
                        var _is_cave_p1 = worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data, _cave_below);
                        var _is_cave_0  = worldgen_get_cave(i, j + 0, _surface_height, _cave_start, _world_seed, _world_data, _cave_below);
                        var _is_cave_m1 = worldgen_get_cave(i, j - 1, _surface_height, _cave_start, _world_seed, _world_data, _cave_below);
                        
                        _queue = (_is_cave_p1 << 0)
                            | (_is_cave_0  << 1)
                            | (_is_cave_m1 << 2);
                        
                        _queue_valid = true;
                    }
                    else
                    {
                        _queue = ((_queue & 0b011) << 1) | worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data, _cave_below);
                    }
                    
                    var _is_cave = (_queue & 0b010);
                    
                    /* resolve relevant biome for this tile */
                    var _target_data = _data;
                    
                    var _cave_biome_id = worldgen_get_biome_cave(i, j, _surface_height, _world_seed, _world_data, _blend_data);
                    
                    if (_cave_biome_id != undefined)
                    {
                        _target_data = _biome_data[$ worldgen_resolve_id(_cave_biome_id)];
                    }
                    else if (_is_cave)
                    {
                        continue;
                    }
                    
                    if (_target_data == undefined) continue;
                    
                    var _length = _target_data.get_structure_length();
                    
                    var _chance_seed = (_world_seed & 0xffff)
                        ^ (abs(_world_seed) >> 16)
                        ^ (i * 1_497_931)
                        ^ (j * 2_693_571);
                    
                    for (var l = 0; l < _length; ++l)
                    {
                        var _structure = _target_data.get_structure(l);
                        
                        if (!chance_seeded(_structure.chance, _chance_seed ^ ((l + 1) * 2_341_113))) continue;
                        
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
                            var _id_max_idx = array_length(_id) - 1;
                            
                            var _generate = true;
                            
                            for (var m = _id_max_idx; m >= 0; --m)
                            {
                                /* continue if bottom tile is air */
                                if (_queue & 0b100) && !(_queue & 0b001)
                                {
                                    if (_structure_data[$ _id[m]].get_placement_type() == STRUCTURE_PLACEMENT_TYPE.FLOOR) continue;
                                }
                                /* continue if top tile is solid */
                                else if !(_queue & 0b100) && (_queue & 0b001)
                                {
                                    if (_structure_data[$ _id[m]].get_placement_type() == STRUCTURE_PLACEMENT_TYPE.CEILING) continue;
                                }
                                else
                                {
                                    if (_structure_data[$ _id[m]].get_placement_type() == STRUCTURE_PLACEMENT_TYPE.INSIDE) continue;
                                }
                                
                                _generate = false;
                                
                                break;
                            }
                            
                            if (_generate)
                            {
                                for (var m = _id_max_idx; m >= 0; --m)
                                {
                                    if (structure_valid(i, j, _id[m], _world_seed)) continue;
                                    
                                    _generate = false;
                                    
                                    break;
                                }
                            }
                            
                            if (_generate)
                            {
                                for (var m = _id_max_idx; m >= 0; --m)
                                {
                                    structure_create(i, j, _id[m], _world_seed);
                                }
                            }
                        }
                        else
                        {
                            var _struct_data_ptr = _structure_data[$ _id];
                            
                            var _placement_type = _struct_data_ptr.get_placement_type();
                            
                            if (_queue & 0b100) && !(_queue & 0b001)
                            {
                                if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                                {
                                    structure_create(i, j, _id, _world_seed);
                                }
                            }
                            else if !(_queue & 0b100) && (_queue & 0b001)
                            {
                                if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                                {
                                    structure_create(i, j, _id, _world_seed);
                                }
                            }
                            else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE)
                            {
                                structure_create(i, j, _id, _world_seed);
                            }
                        }
                    }
                }
            }
        }
    }
}
