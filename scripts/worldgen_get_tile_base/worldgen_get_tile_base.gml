/// @desc Get base tile for terrain generation with horizontal biome blending
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {String} _surface_biome Surface biome ID
/// @param {String} _cave_biome Cave biome ID (or undefined)
/// @param {Real} _surface_height Surface height at this position
/// @param {Bool} _cave_above Whether there is a cave above this position
/// @param {Real} _seed World seed
/// @returns {String} Tile ID
/// @desc Get base tile for terrain generation with horizontal biome blending
/// @param {Real} _x World X position
/// @param {Real} _y World Y position
/// @param {String} _surface_biome Surface biome ID
/// @param {String} _cave_biome Cave biome ID (or undefined)
/// @param {Real} _surface_height Surface height at this position
/// @param {Bool} _cave_above Whether there is a cave above this position
/// @param {Real} _seed World seed
/// @returns {String} Tile ID
function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed)
{
    // Get world data for bedrock/lava calculations
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    // Bedrock layer
    var _bedrock_depth = _world_height - _y;
    if (_bedrock_depth <= _world_data.get_bedrock_depth())
    {
        if (_bedrock_depth <= 1) return "phantasia:bedrock";
        var _bedrock_noise = open_simplex_noise(_x * _world_data.get_bedrock_noise_scale(), _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4) return "phantasia:bedrock";
    }
    // === 3D Density-based terrain (replaces old overhang system) ===
    // Use TerrainShaper for solid tile determination
    var _density = 0;
    if (global.terrain_shaper != undefined)
    {
        _density = global.terrain_shaper.get_density_solid(_x, _y, _seed);
        if (_density < 0) return TILE_EMPTY; // Negative density = air
    }
    
    // Generate context for MaterialProvider
    // Used for evaluating rules and noise-based placement
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 100), 1.0, 2);
    
    var _context = {
        x: _x,
        y: _y,
        surface_height: _surface_height,
        noise: _noise,
        cave_above: _cave_above,
        air_above: (_cave_above ? 1 : 0),
        cave_biome: _cave_biome
        // Add more context properties here as needed by rules
    }
    
    var _biome_data = global.biome_data;
    
    // Cave biome tiles (no horizontal blending for underground)
    if (_cave_biome != undefined)
    {
        var _biome = _biome_data[$ _cave_biome] ?? _biome_data[$ "phantasia:surface/forest"];
        if (_biome != undefined)
        {
            return _biome.get_tile_middle_layer().get_tile(_context);
        }
    }
    
    // Surface biome evaluation
    var _blend_range = _world_data.get_biome_blend_range();
    var _blend_noise_scale = _world_data.get_biome_blend_noise_scale();
    
    // === BIOME TRANSITION SYSTEM (Beaches, etc.) ===
    // Check distance to region boundary for transition biomes
    var _boundary_distance = global.region_generator.get_boundary_distance(_x, _y, 0, _seed);
    var _transition_threshold = _world_data[$ "___transition_threshold"] ?? 24; // Distance in blocks to trigger transition
    
    var _biome_to_use_id = _surface_biome;
    
    if (_boundary_distance < _transition_threshold)
    {
        // We're near a biome boundary - check for transition biome
        var _transition_biome = ___get_transition_biome(_surface_biome, _world_data, _seed, _x);
        if (_transition_biome != undefined)
        {
            // Smooth transition: use noise to blend into transition biome
            var _transition_factor = 1 - (_boundary_distance / _transition_threshold);
            var _transition_noise = open_simplex_noise(_x * 0.05, _y * 0.05 + 2000, 1.0, 2);
            
            if (_transition_noise < _transition_factor * 0.8)
            {
                _biome_to_use_id = _transition_biome;
            }
        }
    }
    
    // === LEGACY HORIZONTAL BLENDING ===
    var _heat = worldgen_get_heat(_x, 0, _seed, _world_data);
    var _humidity = worldgen_get_humidity(_x, 0, _seed, _world_data);
    var _heat_left = worldgen_get_heat(_x - _blend_range, 0, _seed, _world_data);
    var _heat_right = worldgen_get_heat(_x + _blend_range, 0, _seed, _world_data);
    var _humidity_left = worldgen_get_humidity(_x - _blend_range, 0, _seed, _world_data);
    var _humidity_right = worldgen_get_humidity(_x + _blend_range, 0, _seed, _world_data);
    
    var _is_boundary = (_heat != _heat_left) || (_heat != _heat_right) || 
                       (_humidity != _humidity_left) || (_humidity != _humidity_right);
    
    if (_is_boundary && _biome_to_use_id == _surface_biome) // Only apply if not already transitioned
    {
        var _blend_noise = open_simplex_noise(_x * _blend_noise_scale, _y * _blend_noise_scale + 1000, 1.0, 2);
        if (_blend_noise > 0.2)
        {
            var _surface_biome_map = _world_data.get_surface_biome_map();
            if (_blend_noise > 0.55 && (_heat_left != _heat || _humidity_left != _humidity))
            {
                _biome_to_use_id = _surface_biome_map[(_humidity_left << WORLDGEN_SIZE_HEAT_BIT) | _heat_left];
            }
            else if (_blend_noise > 0.2 && (_heat_right != _heat || _humidity_right != _humidity))
            {
                _biome_to_use_id = _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right];
            }
        }
    }
    
    var _biome = _biome_data[$ _biome_to_use_id] ?? _biome_data[$ "phantasia:surface/forest"];
    
    if (_biome != undefined)
    {
        // === STRATIFICATION LOGIC ===
        // Determine tile based on density and exposure
        // 1. Surface (Exposed to Air): Grass/Top Layer
        if (_cave_above)
        {
            return _biome.get_tile_top_layer().get_tile(_context);
        }
        
        // 2. Sub-surface (Near Air): Dirt/Middle Layer
        // Density closer to 0 means we are near the surface/edge.
        // Higher density means we are deeper inside the solid mass.
        // Threshold: 0.0 to 0.7 = Dirt zone (Increased for thicker layer)
        if (_density < 0.7)
        {
            return _biome.get_tile_middle_layer().get_tile(_context);
        }
        
        // 3. Deep Underground: Stone/Fill Layer
        return "phantasia:stone"; 
    }
    
    return TILE_EMPTY;
}

/// @desc Get transition biome between two adjacent biomes
/// @param {String} _current_biome Current biome ID at this position
/// @param {Struct} _world_data World data
/// @param {Real} _seed World seed
/// @param {Real} _x World X position
/// @returns {String|Undefined} Transition biome ID or undefined if no transition
function ___get_transition_biome(_current_biome, _world_data, _seed, _x)
{
    // Look up adjacent region to determine what we're transitioning to
    var _adjacent_region = global.region_generator.get_region(_x + 32, 0, 0, _seed);
    var _adjacent_biome = _adjacent_region.get_surface_biome_id();
    
    // If same biome, no transition needed
    if (_adjacent_biome == _current_biome) return undefined;
    
    // Get transition rules from world data
    var _rules = _world_data.get_surface_biome_transitions();
    if (_rules == undefined) return undefined;
    
    var _biome_data = global.biome_data;
    var _b1 = _biome_data[$ _current_biome];
    var _b2 = _biome_data[$ _adjacent_biome];
    
    if (_b1 == undefined || _b2 == undefined) return undefined;
    
    // Iterate rules
    // Rule format: { result, require_any, require_all, exclude }
    var _rules_count = array_length(_rules);
    for (var i = 0; i < _rules_count; ++i)
    {
        var _rule = _rules[i];
        
        // Check EXCLUDE first
        var _exclude = _rule[$ "exclude"];
        if (_exclude != undefined)
        {
            var _fail = false;
            for (var j = 0; j < array_length(_exclude); ++j)
            {
                var _tag = _exclude[j];
                // If either biome has this excluded tag/ID, fail
                if (_b1.has_tag(_tag) || _b2.has_tag(_tag) || _current_biome == _tag || _adjacent_biome == _tag)
                {
                    _fail = true;
                    break;
                }
            }
            if (_fail) continue;
        }
        
        // Check REQUIRE_ANY (at least one tag/ID must be present in the pair)
        var _require_any = _rule[$ "require_any"];
        if (_require_any != undefined)
        {
            var _found = false;
            for (var j = 0; j < array_length(_require_any); ++j)
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
        
        // Check REQUIRE_ALL (all tags/IDs must be present in the pair)
        var _require_all = _rule[$ "require_all"];
        if (_require_all != undefined)
        {
            var _fail = false;
            for (var j = 0; j < array_length(_require_all); ++j)
            {
                var _tag = _require_all[j];
                // For "require all", the set of tags must be covered by the pair.
                // Interpretation: Each tag in the requirement must exist in EITHER biome.
                if (!(_b1.has_tag(_tag) || _b2.has_tag(_tag) || _current_biome == _tag || _adjacent_biome == _tag))
                {
                    _fail = true;
                    break;
                }
            }
            if (_fail) continue;
        }
        
        // Match found!
        return _rule.result;
    }
    
    return undefined;
}
