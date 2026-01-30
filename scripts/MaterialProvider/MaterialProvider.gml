/// @desc Base struct for block placement logic
function MaterialProvider() constructor
{
    ___items = [];
    ___default_id = TILE_EMPTY;
    
    static add_item = function(_id, _rules = [])
    {
        array_push(___items, {
            id: _id,
            rules: _rules,
            noise_min: -9999, // Accepted by default
            noise_max: 9999
        });
        return self;
    }
    
    static add_item_noise = function(_id, _noise_min, _noise_max, _rules = [])
    {
        array_push(___items, {
            id: _id,
            rules: _rules,
            noise_min: _noise_min,
            noise_max: _noise_max
        });
        return self;
    }
    
    static set_default = function(_id)
    {
        ___default_id = _id;
        return self;
    }
    
    /// @desc Evaluate rules and return tile ID
    /// @param {Struct} _context { x, y, surface_height, noise }
    static get_tile = function(_context)
    {
        return ___evaluate(_context, false);
    }
    
    /// @desc Evaluate rules and return wall ID
    /// @param {Struct} _context { x, y, surface_height, noise }
    static get_wall = function(_context)
    {
        return ___evaluate(_context, true);
    }
    
    /// @desc Internal evaluation logic
    static ___evaluate = function(_context, _is_wall_requested)
    {
        var _noise = _context[$ "noise"] ?? 0;
        var _noise_val = frac(abs(_noise)) * 255; // 0..255 range
        
        for (var i = 0; i < array_length(___items); ++i)
        {
            var _item = ___items[i];
            
            // Wall detection based on ID suffix
            var _item_is_wall = (string_ends_with(_item.id, "_wall") || string_ends_with(_item.id, "_wall_emissive"));
            if (_item_is_wall != _is_wall_requested) continue;
            
            // 1. Check Noise Range
            if (_noise_val < _item.noise_min || _noise_val >= _item.noise_max) continue;
            
            // 2. Check Rules
            var _pass = true;
            for (var j = 0; j < array_length(_item.rules); ++j)
            {
                if (!_item.rules[j].check(_context))
                {
                    _pass = false;
                    break;
                }
            }
            
            if (_pass) return _item.id;
        }
        
        // Walls default to empty if not found, tiles use the explicit default
        return _is_wall_requested ? TILE_EMPTY : ___default_id;
    }
}

/// @desc Base Rule Interface
function MaterialRule() constructor
{
    static check = function(_context) { return true; }
}

/// @desc Checks depth below surface (positive = underground, negative = sky)
function RuleDepth(_min, _max) : MaterialRule() constructor
{
    ___min = _min;
    ___max = _max;
    
    static check = function(_context)
    {
        var _y = _context[$ "y"] ?? 0;
        var _surface_height = _context[$ "surface_height"] ?? 0;
        var _depth = _y - _surface_height;
        
        return (_depth >= ___min && _depth <= ___max);
    }
}

/// @desc Checks if the position has air above it (requires World/Chunk access or simplified assumption)
function RuleAirAbove(_min_blocks) : MaterialRule() constructor
{
    ___min_blocks = _min_blocks;
    
    static check = function(_context)
    {
        return (_context[$ "air_above"] ?? 0) >= ___min_blocks;
    }
}

/// @desc Checks that there are NO solid blocks within N blocks above (for grass under overhangs, etc.)
/// Returns true if NONE of the N blocks above are solid
function RuleSolidAbove(_max_blocks) : MaterialRule() constructor
{
    ___max_blocks = _max_blocks;
    
    static check = function(_context)
    {
        var _x = _context[$ "x"];
        var _y = _context[$ "y"];
        var _seed = global.world_save_data.seed;
        
        // Use WorldGenCore density to check for solid blocks above
        if (global.terrain_shaper == undefined) return true;
        
        for (var i = 1; i <= ___max_blocks; ++i)
        {
            var _check_y = _y - i;
            var _density = global.terrain_shaper.get_density_solid(_x, _check_y, _seed);
            if (_density > 0) return false; // Solid block found above
        }
        
        return true; // No solid blocks within range
    }
}

/// @desc Checks for adjacent tile of specific type (any of 4 cardinal directions)
function RuleAdjacent(_tile_ids) : MaterialRule() constructor
{
    ___tile_ids = is_array(_tile_ids) ? _tile_ids : [_tile_ids];
    
    static check = function(_context)
    {
        var _x = _context[$ "x"];
        var _y = _context[$ "y"];
        
        // Check all 4 directions
        static __offsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        
        for (var i = 0; i < 4; ++i)
        {
            var _ox = __offsets[i][0];
            var _oy = __offsets[i][1];
            var _tile = tile_get(_x + _ox, _y + _oy, CHUNK_DEPTH_DEFAULT);
            if (_tile == TILE_EMPTY) continue;
            
            var _id = _tile.get_id();
            if (array_get_index(___tile_ids, _id) != -1) return true;
        }
        
        return false;
    }
}

/// @desc Checks that there are NO adjacent tiles of specific type
function RuleNotAdjacent(_tile_ids) : MaterialRule() constructor
{
    ___tile_ids = is_array(_tile_ids) ? _tile_ids : [_tile_ids];
    
    static check = function(_context)
    {
        var _x = _context[$ "x"];
        var _y = _context[$ "y"];
        
        static __offsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        
        for (var i = 0; i < 4; ++i)
        {
            var _ox = __offsets[i][0];
            var _oy = __offsets[i][1];
            var _tile = tile_get(_x + _ox, _y + _oy, CHUNK_DEPTH_DEFAULT);
            if (_tile == TILE_EMPTY) continue;
            
            var _id = _tile.get_id();
            if (array_get_index(___tile_ids, _id) != -1) return false; // Found forbidden adjacent
        }
        
        return true;
    }
}

/// @desc Checks for specific biome context (e.g. only in Cave Biome X)
function RuleCaveBiome(_biome_id) : MaterialRule() constructor
{
    ___biome_id = _biome_id;
    
    static check = function(_context)
    {
        return (_context[$ "cave_biome"] == ___biome_id);
    }
}

/// @desc Checks for specific sub-biome from ZoneData (e.g. "cave_lush" even if Zone is Desert)
function RuleSubBiome(_sub_biome_id) : MaterialRule() constructor
{
    ___sub_biome_id = _sub_biome_id;
    
    static check = function(_context)
    {
        return (_context[$ "sub_biome"] == ___sub_biome_id);
    }
}

/// @desc Checks for specific zone (e.g. only spawn in "desert" zone)
function RuleZone(_zone_id) : MaterialRule() constructor
{
    ___zone_id = _zone_id;
    
    static check = function(_context)
    {
        var _zone = _context[$ "zone"];
        if (_zone == undefined) return false;
        return (_zone.get_id() == ___zone_id);
    }
}

/// @desc Checks for random chance based on position
function RuleChance(_chance) : MaterialRule() constructor
{
    ___chance = _chance;
    
    static check = function(_context)
    {
        var _x = _context[$ "x"] ?? 0;
        var _y = _context[$ "y"] ?? 0;
        // Generate a stable seed from world position
        var _seed = (abs(_x) * 73856093) ^ (abs(_y) * 19349663);
        // Add world seed if available
        if (variable_global_exists("world_save_data")) _seed ^= global.world_save_data.seed;
        
        var _res = (((abs(xorshift(_seed)) & 0xff) / 0xff) < ___chance);
        // if (_res) show_debug_message($"RuleChance passed at {_x},{_y} with chance {___chance}");
        return _res;
    }
}

/// @desc Checks if the tile below is of a specific type
function RuleGenerateOn(_tile_ids) : MaterialRule() constructor
{
    ___tile_ids = is_array(_tile_ids) ? _tile_ids : [_tile_ids];
    
    static check = function(_context)
    {
        var _top = _context[$ "top_tile"];
        if (_top == undefined) return true; // Rule passes if context doesn't provide it? Or fail?
        
        for (var i = 0; i < array_length(___tile_ids); ++i)
        {
            var _id = ___tile_ids[i];
            
            // NEW: Handle tags (starts with #)
            if (string_starts_with(_id, "#"))
            {
                var _tag_list = tag_value_parse(_id);
                if (is_array(_tag_list))
                {
                    if (array_get_index(_tag_list, _top) != -1) return true;
                }
                else
                {
                    // show_debug_message($"[MaterialProvider] WARNING: Tag '{_id}' returned non-array: {typeof(_tag_list)}");
                }
            }
            else
            {
                if (_top == _id) return true;
            }
        }
        
        // show_debug_message($"RuleGenerateOn FAILED: top='{_top}', expected={json_stringify(___tile_ids)}");
        return false;
    }
}
