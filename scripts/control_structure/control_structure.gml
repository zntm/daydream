#macro WORLDGEN_STRUCTURE_OFFSET (CHUNK_SIZE * 2)

function control_structure(_x, _y)
{
    var _biome_data = global.biome_data;
    
    var _world_seed = global.world.seed;
    
    for (var i = _x - WORLDGEN_STRUCTURE_OFFSET; i <= _x + WORLDGEN_STRUCTURE_OFFSET; ++i)
    {
        var _surface_height = worldgen_get_surface_height(i, _world_seed);
        
        for (var j = max(_surface_height - 1, _y - WORLDGEN_STRUCTURE_OFFSET); j <= _y + WORLDGEN_STRUCTURE_OFFSET; ++j)
        {
            if (worldgen_get_cave(i, j, _surface_height, _world_seed)) continue;
            
            var _data = _biome_data[$ bg_get_biome(i, j)];
            
            var _length = _data.get_structure_length();
            
            for (var l = 0; l < _length; ++l)
            {
                var _structure = _data.get_structure(l);
                
                var _chance_seed = ((_world_seed & 0xf) * 18_929) + (_world_seed >> 4) + (i * 11) + (j * 64) + (l * 45);
                
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
            }
        }
    }
}