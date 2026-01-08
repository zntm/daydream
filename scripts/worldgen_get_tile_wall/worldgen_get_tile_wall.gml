function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    // Check for sky island walls (inside islands or support pillars)
    if (_y < _surface_height)
    {
         var _is_inside = worldgen_get_sky_island(_x, _y, _seed, _world_data);
         var _is_below = false;
         
         if (!_is_inside)
         {
             _is_below = worldgen_is_below_sky_island(_x, _y, _seed, _world_data);
         }
         
         if (_is_inside || _is_below)
         {
             // Generate noise value for tile variation
             var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 200), 1.0, 2);
             
             // Use surface biome wall for cohesion
             var _biome_data = global.biome_data;
             var _biome = _biome_data[$ _surface_biome] ?? _biome_data[$ "phantasia:surface/forest"];
             if (_biome != undefined) return _biome.get_tile_middle_layer_wall(_noise);
         }
         
         // If above surface and not part of island system, return empty
         return TILE_EMPTY;
    }
    
    // Generate noise value for tile variation
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 200), 1.0, 2);
    
    var _biome_data = global.biome_data;
    
    if (_cave_biome != undefined)
    {
        var _biome = _biome_data[$ _cave_biome] ?? _biome_data[$ "phantasia:surface/forest"];
        if (_biome != undefined) return _biome.get_tile_middle_layer_wall(_noise);
    }
    
    // Fallback if underground but no cave biome found
    if (_y > _surface_height + _world_data.get_surface_min_depth())
    {
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