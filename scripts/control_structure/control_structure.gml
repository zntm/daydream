#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 8)

global.worldgen_structure = {}

function control_structure(_x, _y)
{
    var _biome_data = global.biome_data;
    
    var _world_seed = global.world_save_data.seed;
    
    for (var i = _x - WORLDGEN_STRUCTURE_OFFSET; i <= _x + WORLDGEN_STRUCTURE_OFFSET; ++i)
    {
        var _surface_height = worldgen_get_surface_height(i, _world_seed);
        
        for (var j = max(_surface_height - 1, _y - WORLDGEN_STRUCTURE_OFFSET); j <= _y + WORLDGEN_STRUCTURE_OFFSET; ++j)
        {
            var _index = $"{floor(i / CHUNK_SIZE)}_{floor(j / CHUNK_SIZE)}";
            
            if (global.worldgen_structure[$ _index] != undefined) continue;
            
            if (!worldgen_get_cave(i, j, _surface_height, _world_seed))
            {
                var _data = _biome_data[$ bg_get_biome(i, j)];
                
                var _length = _data.get_structure_length();
                
                for (var l = 0; l < _length; ++l)
                {
                    var _structure = _data.get_structure(l);
                    
                    var _chance_seed = (((_world_seed & 0xff) * 18_929) ^ (_world_seed >> 8)) ^ ((((i * 13) + j) * 18_938)) + ((l + 1) * 450_111);
                    
                    if (!chance_seeded(_structure.chance, _chance_seed)) continue;
                    
                    var _ = global.structure_data[$ _structure.id];
                    
                    var _placement_type = _.get_placement_type();
                    
                    if (_placement_type == STRUCTURE_PLACEMENT_TYPE.FLOOR)
                    {
                        if (worldgen_get_cave(i, j - 1, _surface_height, _world_seed))
                        {
                            structure_create(i * TILE_SIZE, j * TILE_SIZE, _structure.id, _world_seed);
                        }
                    }
                    else if (_placement_type == STRUCTURE_PLACEMENT_TYPE.CEILING)
                    {
                        if (worldgen_get_cave(i, j + 1, _surface_height, _world_seed))
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
    
    for (var i = _x - WORLDGEN_STRUCTURE_OFFSET; i <= _x + WORLDGEN_STRUCTURE_OFFSET; ++i)
    {
        var _surface_height = worldgen_get_surface_height(i, _world_seed);
        
        for (var j = max(_surface_height - 1, _y - WORLDGEN_STRUCTURE_OFFSET); j <= _y + WORLDGEN_STRUCTURE_OFFSET; ++j)
        {
            var _index = $"{floor(i / CHUNK_SIZE)}_{floor(j / CHUNK_SIZE)}";
            
            global.worldgen_structure[$ _index] = true;
        }
    }
}