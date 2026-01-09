/// @param {Bool} _bypass_density_check (Optional) If true, skip density check and assume wall exists
function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed, _bypass_density_check = false)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    // Check for wall existence via density (Z-offset)
    if (!_bypass_density_check)
    {
        // 1. Check if Solid exists (Walls always exist behind solid)
        var _density_solid = global.terrain_generator.get_density_detailed(_x, _y, 0, _world_data, _seed);
        
        // 2. Check if Wall exists (Z-offset for overhang/support)
        var _wall_offset = _world_data.get_wall_noise_offset() ?? 0.15;
        var _density_wall = global.terrain_generator.get_density_detailed(_x, _y, _wall_offset, _world_data, _seed);
        
        if (_density_solid <= 0 && _density_wall <= 0) return TILE_EMPTY;
        // If either is > 0, we place a wall.
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