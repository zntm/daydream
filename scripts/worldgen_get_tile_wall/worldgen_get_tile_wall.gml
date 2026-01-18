function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed, _is_cave_above = false, _modifiers = undefined)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    // === 3D Density-based walls with Z-offset ===
    // Walls use Z-offset density, extending further than solid tiles to create overhangs
    var _density = worldgen_get_density_wall(_x, _y, _seed, undefined, _modifiers);
    if (_density < 0) return TILE_EMPTY; // Negative density = no wall
    
    // Generate noise value (0..1) for coherent tile variation
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 200), 1.0, 2);
    
    var _biome_data = global.biome_data;
    var _biome = undefined;
    
    if (_cave_biome != undefined)
    {
        _biome = _biome_data[$ _cave_biome];
    }
    
    if (_biome == undefined)
    {
        _biome = _biome_data[$ _surface_biome] ?? _biome_data[$ "phantasia:surface/forest"];
    }
    
    if (_biome != undefined)
    {
        // If "surface" access (cave above), use top layer wall (grass side)
        // Otherwise use middle layer wall (dirt/stone side)
        if (_is_cave_above)
        {
            return _biome.get_tile_top_layer_wall(_noise);
        }
        return _biome.get_tile_middle_layer_wall(_noise);
    }
    
    return TILE_EMPTY;
}