function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed)
{
    if (_y < _surface_height)
    {
        return TILE_EMPTY;
    }
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    // Generate noise value (0..1) for coherent tile variation
    // Offset differently from base tiles to avoid identical patterns
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 200), 1.0, 2);
    
    // Overhang Generation check
    var _overhang_threshold = _world_data.get_cave_overhang_threshold();
    if (_overhang_threshold != undefined)
    {
        var _overhang_noise_scale = _world_data.get_cave_overhang_noise_scale();
        var _overhang_noise = open_simplex_noise(_x * _overhang_noise_scale, _y * _overhang_noise_scale + (_seed * 293), 1.0, 2);
        
        if (_overhang_noise < _overhang_threshold)
        {
            return TILE_EMPTY;
        }
    }
    
    var _biome_data = global.biome_data;
    
    if (_cave_biome != undefined)
    {
        var _biome = _biome_data[$ _cave_biome] ?? _biome_data[$ "phantasia:surface/forest"];
        if (_biome != undefined) return _biome.get_tile_middle_layer_wall(_noise);
    }
    
    // Fallback if underground but no cave biome found
    // Fallback if underground but no cave biome found
    // Respect the 8-block surface buffer
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
        // Try to get the first default cave biome
        var _default_caves = _world_data.get_cave_biome_default();
        if (array_length(_default_caves) > 0)
        {
            var _def_biome_id = _default_caves[array_length(_default_caves) - 1].id; 
            var _biome = _biome_data[$ _def_biome_id] ?? _biome_data[$ "phantasia:surface/forest"];
            if (_biome != undefined) return _biome.get_tile_middle_layer_wall(_noise);
        }
    }
    
    var _biome = _biome_data[$ _surface_biome] ?? _biome_data[$ "phantasia:surface/forest"];
    if (_biome != undefined)
    {
        if (_y == _surface_height)
        {
            return _biome.get_tile_top_layer_wall(_noise);
        }
        return _biome.get_tile_middle_layer_wall(_noise);
    }
    
    return TILE_EMPTY;
}