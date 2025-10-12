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
        var _surface_height = worldgen_get_surface_height(i, _world_seed);
        
        var _tile_x = floor(i / CHUNK_SIZE);
        
        if (!ds_map_exists(global.worldgen_structure, i))
        {
            global.worldgen_structure[? i] = ds_map_create();
        }
        
        var _cave_start = worldgen_get_cave_start(i, _world_seed);
        
        var _ds = global.worldgen_structure[? i];
        
        var _ystart = max(_surface_height - 1, _y - WORLDGEN_STRUCTURE_OFFSET);
        var _yend   = _y + WORLDGEN_STRUCTURE_OFFSET;
        
        var _queue =
            (worldgen_get_cave(i, _ystart + 1, _surface_height, _cave_start, _world_seed, _world_data) << 0) |
            (worldgen_get_cave(i, _ystart + 0, _surface_height, _cave_start, _world_seed, _world_data) << 1) |
            (worldgen_get_cave(i, _ystart - 1, _surface_height, _cave_start, _world_seed, _world_data) << 2);
        
        for (var j = _ystart; j <= _yend; {
            ++j;
            
            _queue = (_queue << 1) | worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data);
        })
        {
            if (ds_map_exists(_ds, j))
            {
                j = ((floor(j / CHUNK_SIZE) + 1) * CHUNK_SIZE) - 1;
                
                _queue =
                    (worldgen_get_cave(i, j + 1, _surface_height, _cave_start, _world_seed, _world_data) << 0) |
                    (worldgen_get_cave(i, j + 0, _surface_height, _cave_start, _world_seed, _world_data) << 1);
                
                continue;
            }
            
            global.worldgen_structure[? i][? j] = true;
            
            if (_queue & 0b010) continue;
            
            var _data = _biome_data[$ bg_get_biome(i, j, _surface_height)];
            
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
                
                var _placement_type = _structure_data[$ _structure.id].get_placement_type();
                
                if (_queue & 0b100)
                {
                    if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                    {
                        structure_create(i * TILE_SIZE, j * TILE_SIZE, _structure.id, _world_seed);
                    }
                }
                else if (_queue & 0b001)
                {
                    if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                    {
                        structure_create(i * TILE_SIZE, j * TILE_SIZE, _structure.id, _world_seed);
                    }
                }
                else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.INSIDE)
                {
                	structure_create(i * TILE_SIZE, j * TILE_SIZE, _structure.id, _world_seed);
                }
            }
        }
    }
}