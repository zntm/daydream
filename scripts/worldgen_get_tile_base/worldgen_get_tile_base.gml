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
    
    if (_density > 2.0 && !_cave_above)
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
        var _biome_to_use_id = _surface_biome;
        var _transition_threshold = _world_data[$ "___transition_threshold"] ?? 24;
        var _boundary_distance = (_modifiers != undefined && _modifiers.boundary_dist != undefined) ? _modifiers.boundary_dist : 999;
        
        if (_boundary_distance < _transition_threshold)
        {
            var _current_region = (_modifiers != undefined) ? _modifiers.region : undefined;
            var _transition_biome = ___get_transition_biome(_surface_biome, _world_data, _seed, _x, _current_region);
            
            if (_transition_biome != undefined)
            {
                var _transition_factor = 1 - (_boundary_distance / _transition_threshold);
                var _transition_noise = open_simplex_noise(_x * 0.05, _y * 0.05 + 2000, 1.0, 2);
                
                if (_transition_noise < _transition_factor * 0.8)
                {
                    _biome_to_use_id = _transition_biome;
                }
            }
        }
        
        _biome = _biome_data[$ _biome_to_use_id] ?? _biome_data[$ _default_biome_id];
    }
    
    if (_biome == undefined) return TILE_EMPTY;

    if (_cave_above)
    {
        return _biome.get_tile_top_layer().get_tile(_context);
    }
    
    var _crust_var = open_simplex_noise(_x * 0.015, _seed * 8.3, 1.0, 2);
    var _boundary_wobble = open_simplex_noise(_x * 0.06, _y * 0.06 + (_seed * 15.7), 1.0, 3);
    var _dirt_threshold = 0.6 + (_crust_var * 0.4) + (_boundary_wobble * 0.15);
    
    if (_density < _dirt_threshold)
    {
        return _biome.get_tile_middle_layer().get_tile(_context);
    }
    
    return _stone_id;
}

function ___get_transition_biome(_current_biome, _world_data, _seed, _x, _current_region = undefined)
{
    var _region_gen = global.region_generator;
    
    if (_current_region == undefined)
    {
        _current_region = _region_gen.get_region(_x, 0, 0, _seed);
    }
    
    var _adjacent_region = _region_gen.get_region(_x + 32, 0, 0, _seed);
    
    if (_current_region.get_category() == _adjacent_region.get_category()) return undefined;
    
    var _adjacent_biome = _adjacent_region.get_surface_biome_id();
    if (_adjacent_biome == _current_biome) return undefined;
    
    var _rules = _world_data.get_surface_biome_transitions();
    if (_rules == undefined) return undefined;
    
    var _biome_data = global.biome_data;
    var _b1 = _biome_data[$ _current_biome];
    var _b2 = _biome_data[$ _adjacent_biome];
    
    if (_b1 == undefined || _b2 == undefined) return undefined;
    
    var _rules_count = array_length(_rules);
    for (var i = 0; i < _rules_count; ++i)
    {
        var _rule = _rules[i];
        var _exclude = _rule[$ "exclude"];
        
        if (_exclude != undefined)
        {
            var _fail = false;
            var _exclude_len = array_length(_exclude);
            for (var j = 0; j < _exclude_len; ++j)
            {
                var _tag = _exclude[j];
                if (_b1.has_tag(_tag) || _b2.has_tag(_tag) || _current_biome == _tag || _adjacent_biome == _tag)
                {
                    _fail = true;
                    break;
                }
            }
            if (_fail) continue;
        }
        
        var _require_any = _rule[$ "require_any"];
        if (_require_any != undefined)
        {
            var _found = false;
            var _req_any_len = array_length(_require_any);
            for (var j = 0; j < _req_any_len; ++j)
            {
                var _tag = _require_any[j];
                if (_b1.has_tag(_tag) || _b2.has_tag(_tag) || _current_biome == _tag || _adjacent_biome == _tag)
                {
                    _found = true;
                    break;
                }
            }
            if (!_found) continue;
        }
        
        var _require_all = _rule[$ "require_all"];
        if (_require_all != undefined)
        {
            var _fail = false;
            var _req_all_len = array_length(_require_all);
            for (var j = 0; j < _req_all_len; ++j)
            {
                var _tag = _require_all[j];
                if (!(_b1.has_tag(_tag) || _b2.has_tag(_tag) || _current_biome == _tag || _adjacent_biome == _tag))
                {
                    _fail = true;
                    break;
                }
            }
            if (_fail) continue;
        }
        
        return _rule.result;
    }
    
    return undefined;
}
