function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed)
{
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    // Generate noise value (0..1) for coherent tile variation
    // Offset differently from base tiles to avoid identical patterns
    var _noise = open_simplex_noise(_x * 0.05, _y * 0.05 + (_seed * 200), 1.0, 2);
    
    if (_cave_biome != undefined)
    {
        return global.biome_data[$ _cave_biome].get_tile_middle_layer_wall(_noise);
    }
    
    // Fallback if underground but no cave biome found
    // Fallback if underground but no cave biome found
    // Respect the 8-block surface buffer
    if (_y > _surface_height + 8)
    {
        // Try to get the first default cave biome
        var _default_caves = global.world_data[$ global.world_save_data.dimension].get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome = _default_caves[array_length(_default_caves) - 1].id; 
            return global.biome_data[$ _def_biome].get_tile_middle_layer_wall(_noise);
        }
    }
    
    if (_y == _surface_height)
    {
        return global.biome_data[$ _surface_biome].get_tile_top_layer_wall(_noise);
    }
    
    return global.biome_data[$ _surface_biome].get_tile_middle_layer_wall(_noise);
}