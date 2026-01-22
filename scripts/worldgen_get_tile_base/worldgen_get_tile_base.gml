function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed, _modifiers = undefined)
{
    static _bedrock_id = "phantasia:bedrock";
    static _stone_id = "phantasia:stone";
    static _default_biome_id = "phantasia:surface/forest";
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _biome_data = global.biome_data;
    
    var _world_height = _world_data.get_world_height();
    var _bedrock_depth = _world_height - _y;
    var _max_bedrock = _world_data.get_bedrock_depth();
    
    if (_bedrock_depth <= _max_bedrock)
    {
        if (_bedrock_depth <= 1) return _bedrock_id;
        var _bedrock_noise = open_simplex_noise(_x * _world_data.get_bedrock_noise_scale(), _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4) return _bedrock_id;
    }
    
    var _density = worldgen_get_density_solid(_x, _y, _seed, undefined, _modifiers);
    if (_density < 0) return TILE_EMPTY;
    
    if (_density > 0.8 && !_cave_above)
    {
        return _stone_id;
    }
    
    var _material_noise = worldgen_get_density_material(_x, _y, _seed, undefined, _modifiers);
    var _variation_scale = _world_data.get_tile_variation_noise_scale();
    var _noise = open_simplex_noise(_x * _variation_scale, _y * _variation_scale + (_seed * 100), 1.0, 2);
    
    var _context = {
        x: _x,
        y: _y,
        surface_height: _surface_height,
        noise: _noise,
        material_noise: _material_noise,
        cave_above: _cave_above,
        air_above: (_cave_above ? 1 : 0),
        cave_biome: _cave_biome
    };
    
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

    if (_cave_above)
    {
        return _biome.get_tile_top_layer().get_tile(_context);
    }
    
    var _crust_var = open_simplex_noise(_x * 0.015, _seed * 8.3, 1.0, 2);
    var _boundary_wobble = open_simplex_noise(_x * 0.06, _y * 0.06 + (_seed * 15.7), 1.0, 3);
    var _dirt_threshold = 0.7 + (_crust_var * 0.2) + (_boundary_wobble * 0.1);
    
    if (_density < _dirt_threshold)
    {
        return _biome.get_tile_middle_layer().get_tile(_context);
    }
    
    return _stone_id;
}
