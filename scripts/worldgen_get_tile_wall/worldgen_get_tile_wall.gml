function worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _seed, _is_cave_above = false, _modifiers = undefined)
{
    static _default_biome_id = "phantasia:surface/forest";
    
    var _density = worldgen_get_density_wall(_x, _y, _seed, undefined, _modifiers);
    if (_density < 0) return TILE_EMPTY;
    
    var _biome_data = global.biome_data;
    var _biome = undefined;
    
    if (_cave_biome != undefined)
    {
        _biome = _biome_data[$ _cave_biome];
    }
    
    if (_biome == undefined)
    {
        _biome = _biome_data[$ _surface_biome] ?? _biome_data[$ _default_biome_id];
    }
    
    if (_biome == undefined) return TILE_EMPTY;
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _variation_scale = _world_data.get_tile_variation_noise_scale();
    var _noise = open_simplex_noise(_x * _variation_scale, _y * _variation_scale + (_seed * 200), 1.0, 2);
    
    if (_is_cave_above)
    {
        return _biome.get_tile_top_layer_wall(_noise);
    }
    
    return _biome.get_tile_middle_layer_wall(_noise);
}
