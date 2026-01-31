enum BIOME_TYPE {
    SKY,
    SURFACE,
    OCEAN,
    CAVE
}

function BiomeData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    // Initialize all variables with defaults
    ___background = undefined;
    ___map_colour = 0;
    ___sky_colour = {};
    ___sky_colour_names = [];
    ___sky_colour_length = 0;
    ___light_colour = c_white;
    ___music = undefined;
    
    ___tile_top_layer = undefined;
    ___tile_middle_layer = undefined;
    ___tile_bottom_layer = undefined;
    
    ___foliage = [];
    ___creatures = [];
    ___structures = [];
    
    ___terrain_height_offset = 0;
    ___terrain_amplitude_scale = 1;
    
    ___is_ocean = false;
    ___shore_tiles = undefined;
    ___has_shore_tiles = false;
    
    ___is_skyland = false;

    static set_background = function(_background)
    {
        ___background = _background;
        
        return self;
    }
    
    static get_background = function()
    {
        return self[$ "___background"];
    }
    
    static set_map_colour = function(_map_colour)
    {
        ___map_colour = hex_parse(_map_colour);
        
        return self;
    }
    
    static get_map_colour = function()
    {
        return self[$ "___map_colour"];
    }
    
    static set_sky_colour = function(_sky_colour)
    {
        var _names = struct_get_names(_sky_colour);
        var _length = array_length(_names);
        
        ___sky_colour = {}
        ___sky_colour_names = _names;
        ___sky_colour_length = _length;
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            var _data = _sky_colour[$ _name];
            
            ___sky_colour[$ _name] = (hex_parse(_data.gradient) << 24) | hex_parse(_data.base);
        }
        
        return self;
    }
    
    static get_sky_colour = function()
    {
        return ___sky_colour;
    }
    
    static get_sky_colour_names = function()
    {
        return ___sky_colour_names;
    }
    
    static get_sky_colour_length = function()
    {
        return ___sky_colour_length;
    }
    
    static get_sky_colour_base = function(_diurnal)
    {
        return ___sky_colour[$ _diurnal] & 0xffffff;
    }
    
    static get_sky_colour_gradient = function(_diurnal)
    {
        return (___sky_colour[$ _diurnal] >> 24) & 0xffffff;
    }
    
    static set_light_colour = function(_light_colour)
    {
        ___light_colour = {}
        
        var _names = struct_get_names(_light_colour);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            
            ___light_colour[$ _name] = hex_parse(_light_colour[$ _name]);
        }
        
        return self;
    }
    
    static get_light_colour = function(_diurnal)
    {
        return ___light_colour[$ _diurnal];
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
    
    /// @desc Select a tile ID from a tile layer structure or plain string
    static __select_tile = function(_data, _noise)
    {
        if (_data == undefined) return TILE_EMPTY;
        
        // Handle plain string or array of strings (backwards compatibility/simplicity)
        if (is_string(_data)) return (_data == "$EMPTY") ? TILE_EMPTY : _data;
        if (is_array(_data))
        {
            var _len = array_length(_data);
            if (_len == 0) return TILE_EMPTY;
            return _data[floor(frac(abs(_noise)) * _len)];
        }
        
        // Handle object with base/noise/noise_range
        var _base = _data[$ "base"];
        var _noise_val = _data[$ "noise"];
        var _range = _data[$ "noise_range"];
        
        if (_range != undefined && _noise_val != undefined)
        {
            var _noise_255 = frac(abs(_noise)) * 255;
            if (_noise_255 >= _range[0] && _noise_255 < _range[1])
            {
                return is_array(_noise_val) ? _noise_val[floor(frac(abs(_noise * 1.5)) * array_length(_noise_val))] : _noise_val;
            }
        }
        
        // Default to base
        if (is_array(_base))
        {
            var _len = array_length(_base);
            return _base[floor(frac(abs(_noise)) * _len)];
        }
        
        return _base ?? TILE_EMPTY;
    }
    
    static set_tile_top_layer = function(_data)
    {
        ___tile_top_layer = _data;
        
        return self;
    }
    
    static get_tile_top_layer_base = function(_seed = 0)
    {
        return __select_tile(___tile_top_layer, _seed);
    }
    
    static get_tile_top_layer_wall = function(_seed = 0) // Kept for compatibility, redirects to same logic
    {
        return __select_tile(___tile_top_layer, _seed);
    }
    
    static set_tile_middle_layer = function(_data)
    {
        ___tile_middle_layer = _data;
        
        return self;
    }
    
    static get_tile_middle_layer_base = function(_seed = 0)
    {
        return __select_tile(___tile_middle_layer, _seed);
    }
    
    static get_tile_middle_layer_wall = function(_seed = 0)
    {
        return __select_tile(___tile_middle_layer, _seed);
    }
    
    static set_tile_bottom_layer = function(_data)
    {
        ___tile_bottom_layer = _data;
        
        return self;
    }
    
    static get_tile_bottom_layer_base = function(_seed = 0)
    {
        return __select_tile(___tile_bottom_layer, _seed);
    }
    
    static get_tile_bottom_layer_wall = function(_seed = 0)
    {
        return __select_tile(___tile_bottom_layer, _seed);
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
            ___shore_tiles = _tiles;
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
        return __select_tile(___shore_tiles, _seed);
    }
    
    static get_shore_tile_wall = function(_seed = 0)
    {
        if (!has_shore_tiles()) return undefined;
        return __select_tile(___shore_tiles, _seed);
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