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
        
        // Stride optimization: don't scan every single block if we don't have to.
        // For now, let's scan a grid of points (e.g. every 4th block)
        // or just scan random positions? 
        // Better: Scan positions where props MIGHT spawn based on biome probability, then verify pattern.
        
        var _chunk_size = 32;
        var _chunk_x_start = _chunk.chunk_xstart;
        var _chunk_y_start = _chunk.chunk_ystart;
        
        // Get zone for chunk center (zone lookup is expensive, cache per-chunk)
        var _chunk_zone = undefined;
        if (variable_global_exists("zone_generator") && global.zone_generator != undefined)
        {
            _chunk_zone = global.zone_generator.get_zone(_chunk_x_start + 16, _chunk_y_start + 16, 0, _seed);
        }
        
        for (var i = 0; i < _chunk_size; i += 2) // Stride 2 for efficiency?
        {
            var _x = _chunk_x_start + i;
            var _surface_y = worldgen_get_surface_height(_x, _seed, _world_data);
            
            // Only scan if surface is within this chunk's vertical range (plus/minus margin)
            if (_surface_y < _chunk_y_start - 10 || _surface_y > _chunk_y_start + _chunk_size + 10) continue;
            
            // Get sub-biome at surface (if zone exists)
            var _sub_biome = undefined;
            if (_chunk_zone != undefined)
            {
                var _depth = 5; // Check slightly below surface
                _sub_biome = _chunk_zone.get_cave_biome_id(_x, _surface_y + _depth, 0, _depth, _seed);
            }
            
            // Check patterns at this X, Y
            for (var p = 0; p < array_length(___patterns); ++p)
            {
                var _pattern = ___patterns[p];
                
                // Fast fail: check simple probability first?
                
                if (_pattern.check(_x, _surface_y, _chunk, _world_data, _seed, _chunk_zone, _sub_biome))
                {
                   array_push(_matches, {
                       pattern: _pattern,
                       x: _x,
                       y: _surface_y,
                       zone: _chunk_zone,
                       sub_biome: _sub_biome
                   });
                   
                   // Found a match, maybe skip neighbors to avoid overlapping props?
                }
            }
        }
        
        return _matches;
    }
}

/// @desc Base Pattern
function WorldPattern(_id) constructor
{
    ___id = _id;
    
    /// @returns {Bool} True if pattern matches
    /// @param {Struct.ZoneData} _zone Optional zone data
    /// @param {String} _sub_biome Optional sub-biome ID
    static check = function(_x, _y, _chunk, _world_data, _seed, _zone = undefined, _sub_biome = undefined) { return false; }
    
    /// @desc Generate the prop/content for this pattern
    static generate = function(_x, _y, _chunk) 
    {
        // Default: do nothing
    }
}

/// @desc Matches a specific block arrangement: Tree Roots over Cave
/// Context: Solid block at surface, Air block immediately below (cave roof)
function PatternTreeRootOverCave() : WorldPattern("tree_root_cave") constructor
{
    static check = function(_x, _y, _chunk, _world_data, _seed, _zone = undefined, _sub_biome = undefined)
    {
        // 1. Random chance first (optimization)
        if (!chance_seeded(0.1, _seed + _x * 743)) return false; 
        
        // 2. Check if we are at a "cave roof"
        // We can check the worldgen equations again or look at the chunk (if already generated).
        // Since we are running this likely *during* or *after* terrain gen, we might need access to the data.
        
        // Let's assume this runs AFTER chunk terrain logic but BEFORE we finalize structure arrays
        // We can reuse the `worldgen_get_cave` function for a precise check without reading the array.
        
        var _cave_below = worldgen_get_cave(_x, _y + 2, _y, 0, _seed, _world_data); // Check 2 blocks down
        
        return _cave_below;
    }
    
    static generate = function(_x, _y, _chunk)
    {
        // Place a special tree prop
        // structure_create_instance_layer(...)
        // For now, we just log or tag
        // show_debug_message("Found Tree Root Spot at " + string(_x) + "," + string(_y));
    }
}

