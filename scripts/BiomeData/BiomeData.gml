enum BIOME_TYPE {
    SKY,
    SURFACE,
    OCEAN,
    CAVE
}

function BiomeData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    // Initialization
    ___background = undefined;
    ___map_colour = 0;
    ___sky_colour = {};
    ___sky_colour_names = [];
    ___sky_colour_length = 0;
    ___light_colour = {};
    ___music = [];
    
    ___tile_top_layer = undefined;
    ___tile_middle_layer = undefined;
    ___tile_bottom_layer = undefined;
    ___tile_foliage = undefined;
    
    ___terrain_noise_scale = 0.015625;
    ___terrain_height_offset = -40;
    ___terrain_amplitude_min = 30;
    ___terrain_amplitude_max = 60;
    ___terrain_octaves = 4;
    
    ___is_ocean = false;
    ___is_skyland = false;
    
    ___shore_tiles_base = undefined;
    ___has_shore_tiles = false;
    
    ___creature = [];
    ___creature_length = 0;
    ___structure = [];
    ___structure_length = 0;
    ___salt = 0;
    ___water_color = 0xFFFFFF;

    // --- Background & Map ---
    static set_background = function(_background) { ___background = _background; return self; }
    static get_background = function() { return ___background; }
    
    static set_map_colour = function(_map_colour) { ___map_colour = hex_parse(_map_colour); return self; }
    static get_map_colour = function() { return ___map_colour; }
    
    // --- Sky & Light ---
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
    static get_sky_colour = function() { return ___sky_colour; }
    static get_sky_colour_names = function() { return ___sky_colour_names; }
    static get_sky_colour_length = function() { return ___sky_colour_length; }
    static get_sky_colour_base = function(_diurnal) { return ___sky_colour[$ _diurnal] & 0xffffff; }
    static get_sky_colour_gradient = function(_diurnal) { return (___sky_colour[$ _diurnal] >> 24) & 0xffffff; }
    
    static set_light_colour = function(_light_colour)
    {
        ___light_colour = {}
        var _names = struct_get_names(_light_colour);
        for (var i = 0; i < array_length(_names); ++i)
        {
            var _name = _names[i];
            ___light_colour[$ _name] = hex_parse(_light_colour[$ _name]);
        }
        return self;
    }
    static get_light_colour = function(_diurnal) { return ___light_colour[$ _diurnal]; }
    
    // --- Music ---
    static set_music = function(_music_data)
    {
        ___music = [];
        for (var i = 0; i < array_length(_music_data); ++i)
        {
            var _ = _music_data[i];
            array_push(___music, new Sound(_.id, _.gain));
        }
        return self;
    }
    static get_music = function() { return ___music; }
    
    // --- Terrain Layers (Material Providers) ---
    static set_tile_top_layer = function(_provider) { ___tile_top_layer = _provider; return self; }
    static get_tile_top_layer = function() { return ___tile_top_layer; }
    
    static set_tile_middle_layer = function(_provider) { ___tile_middle_layer = _provider; return self; }
    static get_tile_middle_layer = function() { return ___tile_middle_layer; }
    
    static set_tile_bottom_layer = function(_provider) { ___tile_bottom_layer = _provider; return self; }
    static get_tile_bottom_layer = function() { return ___tile_bottom_layer; }
    
    static set_tile_foliage = function(_provider) { ___tile_foliage = _provider; return self; }
    static get_tile_foliage = function() { return ___tile_foliage; }
    
    // --- Legacy Wrappers (for worldgen compatibility) ---
    static get_tile_top_layer_base = function(_noise) { return ___tile_top_layer.get_tile({ noise: _noise }); }
    static get_tile_top_layer_wall = function(_noise) { return ___tile_top_layer.get_wall({ noise: _noise }); }
    
    static get_tile_middle_layer_base = function(_noise) { return ___tile_middle_layer.get_tile({ noise: _noise }); }
    static get_tile_middle_layer_wall = function(_noise) { return ___tile_middle_layer.get_wall({ noise: _noise }); }
    
    static get_tile_bottom_layer_base = function(_noise) { return ___tile_bottom_layer.get_tile({ noise: _noise }); }
    static get_tile_bottom_layer_wall = function(_noise) { return ___tile_bottom_layer.get_wall({ noise: _noise }); }
    
    static get_tile_foliage_base = function(_noise) { return ___tile_foliage.get_tile({ noise: _noise }); }
    
    // --- Terrain Modifier ---
    static set_terrain_parameters = function(_params)
    {
        if (_params == undefined) return self;
        ___terrain_noise_scale = _params[$ "noise_scale"] ?? 0.015625;
        ___terrain_height_offset = _params[$ "height_offset"] ?? -40;
        ___terrain_amplitude_min = _params[$ "amplitude_min"] ?? 30;
        ___terrain_amplitude_max = _params[$ "amplitude_max"] ?? 60;
        ___terrain_octaves = _params[$ "octaves"] ?? 4;
        return self;
    }
    static get_terrain_noise_scale = function() { return ___terrain_noise_scale; }
    static get_terrain_height_offset = function() { return ___terrain_height_offset; }
    static get_terrain_amplitude_min = function() { return ___terrain_amplitude_min; }
    static get_terrain_amplitude_max = function() { return ___terrain_amplitude_max; }
    static get_terrain_octaves = function() { return ___terrain_octaves; }
    
    // --- Flags ---
    static set_is_ocean = function(_value) { ___is_ocean = _value ?? false; return self; }
    static is_ocean = function() { return ___is_ocean; }
    
    static set_is_skyland = function(_value) { ___is_skyland = _value ?? false; return self; }
    static is_skyland = function() { return ___is_skyland; }
    
    // --- Shore ---
    static set_shore_tiles = function(_provider_base)
    {
        ___shore_tiles_base = _provider_base;
        ___has_shore_tiles = (_provider_base != undefined);
        return self;
    }
    static has_shore_tiles = function() { return ___has_shore_tiles; }
    static get_shore_tile_base = function() { return ___shore_tiles_base; }
    
    // --- Creatures & Structures ---
    static set_creature = function(_creature_data)
    {
        if (_creature_data == undefined) return self;
        ___creature = [];
        ___creature_length = array_length(_creature_data);
        for (var i = 0; i < ___creature_length; ++i)
        {
            var _ = _creature_data[i];
            ___creature[i] = {
                id: _.id,
                amount: smart_value_parse(_.amount),
                chance: _[$ "chance"] ?? 1,
                time: _[$ "time"],
                tile: _[$ "tile"],
                variant: smart_value_parse(_[$ "variant"])
            };
        }
        return self;
    }
    static get_creature = function() { return ___creature; }
    static get_creature_length = function() { return ___creature_length; }
    
    static set_structure = function(_structure_data)
    {
        if (_structure_data == undefined) return self;
        ___structure = _structure_data;
        ___structure_length = array_length(_structure_data);
        return self;
    }
    static get_structure = function(_index) { return ___structure[_index]; }
    static get_structure_length = function() { return ___structure_length; }
    
    // --- Other ---
    static set_salt = function(_salt) { ___salt = _salt; return self; }
    static get_salt = function() { return ___salt; }
    static get_water_color = function() { return ___water_color; }
}