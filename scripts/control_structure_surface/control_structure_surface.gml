function control_structure_surface(_xstart, _xend)
{
    var _biome_data = global.biome_data;
    
    var _world_seed = global.world.seed;
    
    for (var _x = _xstart; _x <= _xend; ++_x)
    {
        var _surface_height = worldgen_get_surface_height(_x, _world_seed);
        
        var _surface_biome = _biome_data[$ worldgen_get_biome_surface(_x, _surface_height, _surface_height, _world_seed)];
        
        var _structure_length = _surface_biome.get_structure_length();
        
        var _x2 = _x * TILE_SIZE;
        var _y2 = _surface_height * TILE_SIZE;
        
        for (var j = 0; j < _structure_length; ++j)
        {
            var _structure = _surface_biome.get_structure(j);
            
            if (!chance_seeded(_structure.chance, (_world_seed / 2) - _x + ((j + 1) * 512))) continue;
            
            if (global.structure_surface[$ _x]) continue;
            
            global.structure_surface[$ _x] = true;
            
            structure_create(_x2, _y2, _structure.id, _world_seed, true);
        }
    }
}