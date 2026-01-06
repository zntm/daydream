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
