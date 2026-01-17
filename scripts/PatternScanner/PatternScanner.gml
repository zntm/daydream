/// @desc System for verifying complex world patterns
function PatternScanner() constructor
{
    ___patterns = [];
    
    static add_pattern = function(_pattern)
    {
        array_push(___patterns, _pattern);
        return self;
    }
    
    /// @desc Scan a chunk context for matches
    /// @param {Struct} _chunk The chunk struct being generated
    /// @param {Struct} _world_data Global world data
    /// @param {Real} _seed World seed
    static scan_chunk = function(_chunk, _world_data, _seed)
    {
        var _matches = [];
        
        var _chunk_size = 32;
        var _chunk_x_start = _chunk.chunk_xstart;
        var _chunk_y_start = _chunk.chunk_ystart;
        
        // Get zone for chunk center (zone lookup is expensive, cache per-chunk)
        var _chunk_zone = undefined;
        if (variable_global_exists("zone_generator") && global.zone_generator != undefined)
        {
            _chunk_zone = global.zone_generator.get_zone(_chunk_x_start + 16, _chunk_y_start + 16, 0, _seed);
        }
        
        for (var i = 0; i < _chunk_size; i += 2) // Stride 2 for efficiency
        {
            var _x = _chunk_x_start + i;
            var _surface_y = worldgen_get_surface_height(_x, _seed, _world_data);
            
            // Only scan if surface is within this chunk's vertical range (plus/minus margin)
            if (_surface_y < _chunk_y_start - 10 || _surface_y > _chunk_y_start + _chunk_size + 10) continue;
            
            // Get sub-biome at surface (if zone exists)
            var _sub_biome = undefined;
            if (_chunk_zone != undefined)
            {
                var _depth = 5;
                _sub_biome = _chunk_zone.get_cave_biome_id(_x, _surface_y + _depth, 0, _depth, _seed);
            }
            
            // Build context for rule evaluation
            var _context = {
                x: _x,
                y: _surface_y,
                chunk: _chunk,
                world_data: _world_data,
                seed: _seed,
                zone: _chunk_zone,
                sub_biome: _sub_biome
            };
            
            // Check patterns at this X, Y
            for (var p = 0; p < array_length(___patterns); ++p)
            {
                var _pattern = ___patterns[p];
                
                if (_pattern.check_rules(_context))
                {
                   array_push(_matches, {
                       pattern: _pattern,
                       x: _x,
                       y: _surface_y,
                       zone: _chunk_zone,
                       sub_biome: _sub_biome,
                       context: _context
                   });
                }
            }
        }
        
        return _matches;
    }
}

// ============================================================================
// PATTERN RULES - Composable conditions for pattern matching
// ============================================================================

/// @desc Base Pattern Rule
function PatternRule() constructor
{
    /// @desc Evaluate this rule against context
    /// @param {Struct} _context Pattern evaluation context
    /// @returns {Bool} True if rule passes
    static evaluate = function(_context) { return true; }
}

/// @desc Rule: Random chance
function PatternRuleChance(_probability) : PatternRule() constructor
{
    ___probability = _probability;
    
    static evaluate = function(_context)
    {
        return chance_seeded(___probability, _context.seed + _context.x * 743);
    }
}

/// @desc Rule: Must be in specific biome(s)
function PatternRuleBiome(_biome_ids) : PatternRule() constructor
{
    ___biome_ids = is_array(_biome_ids) ? _biome_ids : [_biome_ids];
    
    static evaluate = function(_context)
    {
        if (_context.sub_biome == undefined) return false;
        
        for (var i = 0; i < array_length(___biome_ids); ++i)
        {
            if (___biome_ids[i] == _context.sub_biome) return true;
        }
        return false;
    }
}

/// @desc Rule: Must be within height range
function PatternRuleHeight(_min_y, _max_y) : PatternRule() constructor
{
    ___min_y = _min_y;
    ___max_y = _max_y;
    
    static evaluate = function(_context)
    {
        return (_context.y >= ___min_y) && (_context.y <= ___max_y);
    }
}

/// @desc Rule: Check block at relative offset (is air, is solid, is specific tile)
function PatternRuleBlock(_offset_x, _offset_y, _check_type, _tile_id = undefined) : PatternRule() constructor
{
    ___offset_x = _offset_x;
    ___offset_y = _offset_y;
    ___check_type = _check_type; // "air", "solid", "cave", "tile"
    ___tile_id = _tile_id;
    
    static evaluate = function(_context)
    {
        var _check_x = _context.x + ___offset_x;
        var _check_y = _context.y + ___offset_y;
        
        switch (___check_type)
        {
            case "air":
            case "cave":
                var _surface_height = worldgen_get_surface_height(_check_x, _context.seed, _context.world_data);
                return worldgen_get_cave(_check_x, _check_y, _surface_height, 0, _context.seed, _context.world_data);
                
            case "solid":
                var _surface_height = worldgen_get_surface_height(_check_x, _context.seed, _context.world_data);
                return !worldgen_get_cave(_check_x, _check_y, _surface_height, 0, _context.seed, _context.world_data);
                
            case "tile":
                // Would need to read from chunk data - for now return true
                return true;
        }
        
        return false;
    }
}

/// @desc Rule: Must be above a cave (roof placement)
function PatternRuleAboveCave(_depth_check = 2) : PatternRule() constructor
{
    ___depth_check = _depth_check;
    
    static evaluate = function(_context)
    {
        var _cave_below = worldgen_get_cave(_context.x, _context.y + ___depth_check, _context.y, 0, _context.seed, _context.world_data);
        return _cave_below;
    }
}

/// @desc Rule: Combine multiple rules with AND
function PatternRuleAnd(_rules) : PatternRule() constructor
{
    ___rules = _rules;
    
    static evaluate = function(_context)
    {
        for (var i = 0; i < array_length(___rules); ++i)
        {
            if (!___rules[i].evaluate(_context)) return false;
        }
        return true;
    }
}

/// @desc Rule: Combine multiple rules with OR
function PatternRuleOr(_rules) : PatternRule() constructor
{
    ___rules = _rules;
    
    static evaluate = function(_context)
    {
        for (var i = 0; i < array_length(___rules); ++i)
        {
            if (___rules[i].evaluate(_context)) return true;
        }
        return false;
    }
}

// ============================================================================
// PATTERN ACTIONS - Things to do when a pattern matches
// ============================================================================

/// @desc Base Pattern Action
function PatternAction() constructor
{
    /// @desc Execute this action
    /// @param {Struct} _context Pattern evaluation context
    static execute = function(_context) { }
}

/// @desc Action: Place a tile at relative offset
function PatternActionPlaceTile(_tile_id, _offset_x = 0, _offset_y = 0, _depth = CHUNK_DEPTH_DEFAULT) : PatternAction() constructor
{
    ___tile_id = _tile_id;
    ___offset_x = _offset_x;
    ___offset_y = _offset_y;
    ___depth = _depth;
    
    static execute = function(_context)
    {
        var _chunk = _context.chunk;
        var _target_x = _context.x + ___offset_x - _chunk.chunk_xstart;
        var _target_y = _context.y + ___offset_y - _chunk.chunk_ystart;
        
        // Bounds check
        if (_target_x < 0 || _target_x >= CHUNK_SIZE || _target_y < 0 || _target_y >= CHUNK_SIZE) return;
        
        var _data = global.item_data[$ ___tile_id];
        if (_data != undefined)
        {
            var _index = (is_struct(_data.get_placement_index()) ? smart_value(_data.get_placement_index()) : _data.get_placement_index());
            _chunk.chunk[@ (___depth << (CHUNK_SIZE_BIT * 2)) | (_target_y << CHUNK_SIZE_BIT) | _target_x] = new Tile(___tile_id).set_index(_index);
            _chunk.chunk_display |= 1 << ___depth;
            ++_chunk.chunk_count[@ ___depth];
        }
    }
}

/// @desc Action: Spawn a structure at relative offset
function PatternActionSpawnStructure(_structure_id, _offset_x = 0, _offset_y = 0) : PatternAction() constructor
{
    ___structure_id = _structure_id;
    ___offset_x = _offset_x;
    ___offset_y = _offset_y;
    
    static execute = function(_context)
    {
        var _target_x = _context.x + ___offset_x;
        var _target_y = _context.y + ___offset_y;
        
        structure_create(___structure_id, _target_x * TILE_SIZE, _target_y * TILE_SIZE, _context.seed);
    }
}

/// @desc Action: Run another pattern at offset (chaining)
function PatternActionChain(_pattern, _offset_x = 0, _offset_y = 0) : PatternAction() constructor
{
    ___pattern = _pattern;
    ___offset_x = _offset_x;
    ___offset_y = _offset_y;
    
    static execute = function(_context)
    {
        // Create modified context with offset position
        var _chained_context = {
            x: _context.x + ___offset_x,
            y: _context.y + ___offset_y,
            chunk: _context.chunk,
            world_data: _context.world_data,
            seed: _context.seed,
            zone: _context.zone,
            sub_biome: _context.sub_biome
        };
        
        // Check and execute chained pattern
        if (___pattern.check_rules(_chained_context))
        {
            ___pattern.execute_actions(_chained_context);
        }
    }
}

/// @desc Action: Execute multiple actions in sequence
function PatternActionSequence(_actions) : PatternAction() constructor
{
    ___actions = _actions;
    
    static execute = function(_context)
    {
        for (var i = 0; i < array_length(___actions); ++i)
        {
            ___actions[i].execute(_context);
        }
    }
}

// ============================================================================
// WORLD PATTERN - Composable pattern using rules and actions
// ============================================================================

/// @desc Base Pattern with composable rules and actions
function WorldPattern(_id) constructor
{
    ___id = _id;
    ___rules = [];
    ___actions = [];
    
    /// @desc Add a rule to this pattern
    static add_rule = function(_rule)
    {
        array_push(___rules, _rule);
        return self;
    }
    
    /// @desc Add an action to this pattern
    static add_action = function(_action)
    {
        array_push(___actions, _action);
        return self;
    }
    
    /// @desc Check all rules against context
    /// @param {Struct} _context Pattern evaluation context
    /// @returns {Bool} True if all rules pass
    static check_rules = function(_context)
    {
        for (var i = 0; i < array_length(___rules); ++i)
        {
            if (!___rules[i].evaluate(_context)) return false;
        }
        return true;
    }
    
    /// @desc Execute all actions
    /// @param {Struct} _context Pattern evaluation context
    static execute_actions = function(_context)
    {
        for (var i = 0; i < array_length(___actions); ++i)
        {
            ___actions[i].execute(_context);
        }
    }
    
    /// @desc Legacy check function for backwards compatibility
    static check = function(_x, _y, _chunk, _world_data, _seed, _zone = undefined, _sub_biome = undefined)
    {
        var _context = {
            x: _x,
            y: _y,
            chunk: _chunk,
            world_data: _world_data,
            seed: _seed,
            zone: _zone,
            sub_biome: _sub_biome
        };
        return check_rules(_context);
    }
    
    /// @desc Legacy generate function for backwards compatibility
    static generate = function(_x, _y, _chunk)
    {
        var _context = {
            x: _x,
            y: _y,
            chunk: _chunk,
            world_data: global.world_data[$ global.world_save_data.dimension],
            seed: global.world_save_data.seed,
            zone: undefined,
            sub_biome: undefined
        };
        execute_actions(_context);
    }
}

// ============================================================================
// EXAMPLE PATTERNS - Demonstrating the new system
// ============================================================================

/// @desc Tree Roots over Cave - Using new composable system
/// Example: Pine tree only spawns if above a cave, then places mushrooms and roots
function PatternTreeRootOverCave() : WorldPattern("tree_root_cave") constructor
{
    // Add rules
    add_rule(new PatternRuleChance(0.1));       // 10% base chance
    add_rule(new PatternRuleAboveCave(2));      // Must be above a cave (2 blocks down)
    
    // Add actions (when pattern matches)
    // - Could add: place tree, place mushrooms around, place dirt below
    // For now just a stub
}

