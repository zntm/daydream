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
function worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _seed, _modifiers = undefined)
{
    // Get world data for bedrock/lava calculations
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    var _biome_data = global.biome_data;
    
    // Bedrock layer
    var _bedrock_depth = _world_height - _y;
    if (_bedrock_depth <= _world_data.get_bedrock_depth())
    {
        if (_bedrock_depth <= 1) return "phantasia:bedrock";
        var _bedrock_noise = open_simplex_noise(_x * _world_data.get_bedrock_noise_scale(), _seed * 50, 1.0, 1);
        if (_bedrock_noise > (_bedrock_depth - 1) * 0.4) return "phantasia:bedrock";
    }
    // === 3D Density-based terrain ===
    var _density = worldgen_get_density_solid(_x, _y, _seed, undefined, _modifiers);
    if (_density < 0) return TILE_EMPTY; // Negative density = air
    
    // Sample material noise for organic variation
    var _material_noise = worldgen_get_density_material(_x, _y, _seed, undefined, _modifiers);
    
    // Generate context for MaterialProvider
    // Used for evaluating rules and noise-based placement
    var _noise = open_simplex_noise(_x * _world_data.get_tile_variation_noise_scale(), _y * _world_data.get_tile_variation_noise_scale() + (_seed * 100), 1.0, 2);
    
    var _context = {
        x: _x,
        y: _y,
        surface_height: _surface_height,
        noise: _noise,
        material_noise: _material_noise,
        cave_above: _cave_above,
        air_above: (_cave_above ? 1 : 0),
        cave_biome: _cave_biome
        // Add more context properties here as needed by rules
    }
    
    // === UNIFIED BIOME RESOLUTION ===
    // Determine which biome config to use for this block
    var _biome = undefined;
    
    // 1. Cave Biome Priority
    if (_cave_biome != undefined)
    {
        _biome = _biome_data[$ _cave_biome];
    }
    
    // 2. Surface Biome & Transitions (if no cave biome or fallback needed)
    if (_biome == undefined)
    {
        var _biome_to_use_id = _surface_biome;
        
        // === BIOME TRANSITION SYSTEM ===
        var _blend_range = _world_data.get_biome_blend_range();
        
        // Check distance to region boundary for transition biomes
        var _boundary_distance = (_modifiers != undefined && _modifiers.boundary_dist > 0) ? _modifiers.boundary_dist : global.region_generator.get_boundary_distance(_x, _y, 0, _seed);
        var _transition_threshold = _world_data[$ "___transition_threshold"] ?? 24;
        
        if (_boundary_distance < _transition_threshold)
        {
            var _current_region = ((_modifiers != undefined) ? _modifiers.region : undefined);
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
        
        _biome = _biome_data[$ _biome_to_use_id] ?? _biome_data[$ "phantasia:surface/forest"];
    }
    
    // Safety check
    if (_biome == undefined) return TILE_EMPTY;

    // === STRATIFICATION LOGIC ===
    // 1. Surface (Exposed to Air): Grass/Top Layer
    // Valid for both Surface and Cave biomes (e.g. Cave Floor)
    if (_cave_above)
    {
        return _biome.get_tile_top_layer().get_tile(_context);
    }
    
    // 2. Sub-surface (Near Air): Dirt/Middle Layer
    // Density closer to 0 means we are near the surface/edge.
    
    // --- ORGANIC REFINEMENTS ---
    // A. Continuous "Crust" variation (large-scale waves of soil depth)
    var _crust_var = open_simplex_noise(_x * 0.015, _seed * 8.3, 1.0, 2);
    
    // B. Smooth "Blobby" boundary (medium-scale wobble for rounded transitions)
    var _boundary_wobble = open_simplex_noise(_x * 0.06, _y * 0.06 + (_seed * 15.7), 1.0, 3);
    
    // Calculate dynamic threshold for dirt layer
    var _dirt_threshold = 0.6 + (_crust_var * 0.4) + (_boundary_wobble * 0.15);
    
    if (_density < _dirt_threshold)
    {
        return _biome.get_tile_middle_layer().get_tile(_context);
    }
    
    // 3. Deep Underground: Stone/Fill Layer
    // Use 3D material noise for organic variation
    if (_material_noise > 0.4)
    {
        // Pockets of other materials (stone variants, gravel, etc.)
        // For now let's just use it to vary the "type" of stone or use it for gravel patches
        return "phantasia:stone"; 
    }
    
    return "phantasia:stone";
}

/// @desc Get transition biome between two adjacent biomes
/// @param {String} _current_biome Current biome ID at this position
/// @param {Struct} _world_data World data
/// @param {Real} _seed World seed
/// @param {Real} _x World X position
/// @returns {String|Undefined} Transition biome ID or undefined if no transition
function ___get_transition_biome(_current_biome, _world_data, _seed, _x, _current_region = undefined)
{
    // Look up current region to compare category
    if (_current_region == undefined)
    {
        _current_region = global.region_generator.get_region(_x, 0, 0, _seed);
    }
    
    // Look up adjacent region to determine what we're transitioning to
    var _adjacent_region = global.region_generator.get_region(_x + 32, 0, 0, _seed);
    
    // If regions are in the same category (e.g. both Temperate), ignore biome transitions
    // This allows "Birch Forest" and "Rocky Plains" to meet naturally without a transition seam
    if (_current_region.get_category() == _adjacent_region.get_category()) return undefined;
    
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
