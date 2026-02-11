enum BIOME_TYPE {
    SKY,
    SURFACE,
    OCEAN,
    CAVE
}

/// @desc Safely get sky colour from a biome/ID/region object
function worldgen_get_sky_colour(_target, _time)
{
    if (_target == undefined) return c_black;
    
    // Resolve ID if string
    if (is_string(_target))
    {
        var _biome = global.biome_data[$ _target];
        if (_biome != undefined) return _biome.get_sky_colour(_time);
        
        var _region = global.region_data[$ _target];
        if (_region != undefined) return _region.get_sky_colour(_time);
        
        return c_black;
    }
    
    // Check for method directly
    if (variable_struct_exists(_target, "get_sky_colour"))
    {
        return _target.get_sky_colour(_time);
    }
    
    return c_black;
}

/// @desc Safely get light colour from a biome/ID/region object
function worldgen_get_light_colour(_target, _time)
{
    if (_target == undefined) return c_white;
    
    // Resolve ID if string
    if (is_string(_target))
    {
        var _biome = global.biome_data[$ _target];
        if (_biome != undefined) return _biome.get_light_colour(_time);
        
        var _region = global.region_data[$ _target];
        if (_region != undefined) return _region.get_light_colour(_time);
        
        return c_white;
    }
    
    // Check for method directly
    if (variable_struct_exists(_target, "get_light_colour"))
    {
        return _target.get_light_colour(_time);
    }
    
    return c_white;
}

/// @desc Safely get background data from a biome/ID/region object
function worldgen_get_background(_target)
{
    if (_target == undefined) return undefined;
    
    // Resolve ID if string
    if (is_string(_target))
    {
        var _biome = global.biome_data[$ _target];
        if (_biome != undefined) return _biome.get_background();
        
        var _region = global.region_data[$ _target];
        if (_region != undefined) return _region.get_background();
        
        return undefined;
    }
    
    // Check for method directly
    if (variable_struct_exists(_target, "get_background"))
    {
        return _target.get_background();
    }
    
    return undefined;
}

/// @desc Safely get music data from a biome/ID/region object
function worldgen_get_music(_target)
{
    if (_target == undefined) return undefined;
    
    // Resolve ID if string
    if (is_string(_target))
    {
        var _biome = global.biome_data[$ _target];
        if (_biome != undefined) return _biome.get_music();
        
        var _region = global.region_data[$ _target];
        if (_region != undefined) return _region.get_music();
        
        return undefined;
    }
    
    // Check for method directly
    if (variable_struct_exists(_target, "get_music"))
    {
        return _target.get_music();
    }
    
    return undefined;
}

function BiomeData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    static set_background = function(_background)
    {
        ___background = _background;
        
        return self;
    }
    
    static get_background = function()
    {
        return self[$ "___background"];
    }
    
    
    
    static set_sky_colour = function(_sky_colour)
    {
        var _points = _sky_colour[$ "points"];
        var _length = array_length(_points);
        
        ___sky_colour_points = array_create(_length);
        
        for (var i = 0; i < _length; ++i)
        {
            ___sky_colour_points[i] = {
                position: _points[i].position,
                color: hex_parse(_points[i].color)
            };
        }
        
        // Sort by position just in case
        array_sort(___sky_colour_points, function(_a, _b) { return _a.position - _b.position; });
        
        return self;
    }
    
    static __get_gradient_colour = function(_points, _time)
    {
        var _cnt = array_length(_points);
        if (_cnt == 0) return c_black;
        
        // Check segments
        for (var i = 0; i < _cnt - 1; ++i)
        {
            var _p0 = _points[i];
            var _p1 = _points[i+1];
            
            if (_time >= _p0.position && _time <= _p1.position)
            {
                var _t = (_time - _p0.position) / (_p1.position - _p0.position);
                return merge_color(_p0.color, _p1.color, _t);
            }
        }
        
        // Handle wrapping (Night -> Dawn)
        var _first = _points[0];
        var _last = _points[_cnt-1];
        
        if (_time < _first.position)
        {
             var _len = (1.0 - _last.position) + _first.position;
             var _pos = (_time + (1.0 - _last.position));
             var _t = _pos / _len;
             return merge_color(_last.color, _first.color, _t);
        }
        
        if (_time > _last.position)
        {
             var _len = (1.0 - _last.position) + _first.position;
             var _pos = (_time - _last.position);
             var _t = _pos / _len;
             return merge_color(_last.color, _first.color, _t);
        }
        
        return _first.color;
    }
    
    static get_sky_colour = function(_time)
    {
        if (___sky_colour_points == undefined) return c_black;
        return __get_gradient_colour(___sky_colour_points, _time);
    }
    
    static set_light_colour = function(_light_colour)
    {
        var _points = _light_colour[$ "points"];
        var _length = array_length(_points);
        
        ___light_colour_points = array_create(_length);
        
        for (var i = 0; i < _length; ++i)
        {
            ___light_colour_points[i] = {
                position: _points[i].position,
                color: hex_parse(_points[i].color)
            };
        }
        
        array_sort(___light_colour_points, function(_a, _b) { return _a.position - _b.position; });
        
        return self;
    }
    
    static get_light_colour = function(_time)
    {
        if (___light_colour_points == undefined) return c_white;
        return __get_gradient_colour(___light_colour_points, _time);
    }
    
    static set_music = function(_music)
    {
        ___music = [];
        
        var _length = array_length(_music);
        
        for (var i = 0; i < _length; ++i)
        {
            var _ = _music[i];
            
            array_push(___music, new Sound(_.id, _.gain));
        }
        
        return self;
    }
    
    static get_music = function(_music)
    {
        return self[$ "___music"];
    }
    
    /// @desc Parse tile array data into weighted entry format
    static __parse_tile_array = function(_data)
    {
        if (is_array(_data))
        {
            var _length = array_length(_data);
            var _entries = array_create(_length);
            var _total_weight = 0;
            
            for (var i = 0; i < _length; ++i)
            {
                var _entry = _data[i];
                var _weight = _entry[$ "weight"] ?? 1;
                
                var _id = _entry.id;
                if (_id == "$EMPTY") _id = TILE_EMPTY;
                
                _total_weight += _weight;
                _entries[@ i] = {
                    id: _id,
                    weight: _weight,
                    cumulative_weight: _total_weight,
                    noise_min: _entry[$ "noise_min"],
                    noise_max: _entry[$ "noise_max"]
                }
            }
            
            return { entries: _entries, total_weight: _total_weight }
        }
        else
        {
            // Legacy single-entry format
            var _id = _data.id;
            if (_id == "$EMPTY") _id = TILE_EMPTY;
            
            return { entries: [{ id: _id, weight: 1, cumulative_weight: 1 }], total_weight: 1 }
        }
    }
    
    /// @desc Get random tile ID from weighted entries using noise value (0..1)
    static __get_weighted_tile = function(_parsed, _noise)
    {
        var _entries = _parsed.entries;
        var _total = _parsed.total_weight;
        
        if (array_length(_entries) == 1)
        {
            return _entries[0].id;
        }
        
        // Scale noise to 0..255 for range checks
        var _noise_255 = frac(abs(_noise)) * 255;
        
        // 1. Check explicit ranges
        for (var i = 0; i < array_length(_entries); ++i)
        {
            var _e = _entries[i];
            if (_e.noise_min != undefined)
            {
                var _min = _e.noise_min;
                var _max = _e.noise_max ?? 256;
                
                if (_noise_255 >= _min) && (_noise_255 < _max)
                {
                    return _e.id;
                }
            }
        }
        
        // 2. Fallback to weighted random
        // Use noise value (0..1) mapped to total weight
        var _roll = frac(abs(_noise)) * _total;
        
        for (var i = 0; i < array_length(_entries); ++i)
        {
            if (_roll < _entries[i].cumulative_weight)
            {
                return _entries[i].id;
            }
        }
        
        return _entries[0].id;
    }
    
    static set_tile_top_layer = function(_data)
    {
        ___tile_top_layer_base = __parse_tile_array(_data.base);
        ___tile_top_layer_wall = __parse_tile_array(_data.wall);
        
        return self;
    }
    
    static get_tile_top_layer_base = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_top_layer_base, _seed);
    }
    
    static get_tile_top_layer_wall = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_top_layer_wall, _seed);
    }
    
    static set_tile_middle_layer = function(_data)
    {
        ___tile_middle_layer_base = __parse_tile_array(_data.base);
        ___tile_middle_layer_wall = __parse_tile_array(_data.wall);
        
        return self;
    }
    
    static get_tile_middle_layer_base = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_middle_layer_base, _seed);
    }
    
    static get_tile_middle_layer_wall = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_middle_layer_wall, _seed);
    }
    
    static set_tile_bottom_layer = function(_data)
    {
        ___tile_bottom_layer_base = __parse_tile_array(_data.base);
        ___tile_bottom_layer_wall = __parse_tile_array(_data.wall);
        
        return self;
    }
    
    static get_tile_bottom_layer_base = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_bottom_layer_base, _seed);
    }
    
    static get_tile_bottom_layer_wall = function(_seed = 0)
    {
        return __get_weighted_tile(___tile_bottom_layer_wall, _seed);
    }
    
    static set_terrain_modifier = function(_modifier)
    {
        if (_modifier != undefined)
        {
            ___terrain_height_offset = _modifier[$ "height_offset"] ?? 0;
            ___terrain_amplitude_scale = _modifier[$ "amplitude_scale"] ?? 1;
        }
        
        return self;
    }
    
    static get_terrain_height_offset = function()
    {
        return self[$ "___terrain_height_offset"] ?? 0;
    }
    
    static get_terrain_amplitude_scale = function()
    {
        return self[$ "___terrain_amplitude_scale"] ?? 1;
    }
    
    static set_is_ocean = function(_value)
    {
        ___is_ocean = _value ?? false;
        
        return self;
    }
    
    static is_ocean = function()
    {
        return self[$ "___is_ocean"] ?? false;
    }
    
    static set_shore_tiles = function(_tiles)
    {
        if (_tiles != undefined)
        {
            ___shore_tiles_base = __parse_tile_array(_tiles.base);
            ___shore_tiles_wall = __parse_tile_array(_tiles.wall);
            ___has_shore_tiles = true;
        }
        else
        {
            ___has_shore_tiles = false;
        }
        
        return self;
    }
    
    static has_shore_tiles = function()
    {
        return self[$ "___has_shore_tiles"] ?? false;
    }
    
    static get_shore_tile_base = function(_seed = 0)
    {
        if (!has_shore_tiles()) return undefined;
        return __get_weighted_tile(___shore_tiles_base, _seed);
    }
    
    static get_shore_tile_wall = function(_seed = 0)
    {
        if (!has_shore_tiles()) return undefined;
        return __get_weighted_tile(___shore_tiles_wall, _seed);
    }
    
    static set_is_skyland = function(_value)
    {
        ___is_skyland = _value ?? false;
        
        return self;
    }
    
    static is_skyland = function()
    {
        return self[$ "___is_skyland"] ?? false;
    }
    
    static set_tile_foliage = function(_foliage)
    {
        ___tile_foliage = _foliage;
        ___tile_foliage_length = array_length(_foliage);
        
        return self;
    }
    
    static get_tile_middle_layer_foliage = function(_index)
    {
        return ___tile_foliage[_index];
    }
    
    static get_tile_middle_layer_foliage_length = function()
    {
        return self[$ "___tile_foliage_length"] ?? 0;
    }
    
    static set_creature = function(_creature)
    {
        if (_creature != undefined)
        {
            var _length = array_length(_creature);
            
            ___creature = [];
            ___creature_length = _length;
            
            for (var i = 0; i < _length; ++i)
            {
                var _ = _creature[i];
                
                ___creature[@ i] = {
                    id: _.id,
                    amount: smart_value_parse(_.amount),
                    chance: _[$ "chance"] ?? 1,
                    time: _[$ "time"],
                    tile: _[$ "tile"],
                    variant: smart_value_parse(_[$ "variant"])
                }
            }
        }
        
        return self;
    }
    
    static get_creature = function()
    {
        return self[$ "___creature"];
    }
    
    static get_creature_length = function()
    {
        return self[$ "___creature_length"] ?? 0;
    }
    
    static set_structure = function(_structure)
    {
        ___structure = _structure;
        ___structure_length = array_length(_structure);
        
        return self;
    }
    
    static get_structure = function(_index)
    {
        return ___structure[_index];
    }
    
    static get_structure_length = function()
    {
        return self[$ "___structure_length"] ?? 0;
    }
    
    static set_salt = function(_salt)
    {
        ___salt = _salt;
        
        return self;
    }
    
    static get_salt = function()
    {
        return self[$ "___salt"] ?? 0;
    }
}