enum BIOME_TYPE {
    SKY,
    SURFACE,
    OCEAN,
    CAVE
}

function BiomeData(_name, _type) constructor
{
    ___name = _name;
    
    static get_name = function()
    {
        return ___name;
    }
    
    ___type = _type;
    
    static get_type = function()
    {
        return ___type;
    }
    
    static set_map_colour = function(_map_colour)
    {
        ___map_colour = hex_parse(_map_colour);
        
        return self;
    }
    
    static get_map_colour = function()
    {
        return ___map_colour;
    }
    
    static set_sky_colour = function(_sky_colour)
    {
        ___sky_colour = {}
        
        var _names = struct_get_names(_sky_colour);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            var _data = _sky_colour[$ _name];
            
            ___sky_colour[$ _name] = (hex_parse(_data.gradient) << 24) | hex_parse(_data.base);
        }
        
        return self;
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
    
    static set_tile_top_layer = function(_data)
    {
        ___tile_top_layer_base = _data.base;
        ___tile_top_layer_wall = _data.wall;
    }
    
    static get_tile_top_layer_base = function()
    {
        return ___tile_top_layer_base;
    }
    
    static get_tile_top_layer_wall = function()
    {
        return ___tile_top_layer_wall;
    }
    
    static set_tile_sub_layer = function(_data)
    {
        ___tile_sub_layer_base = _data.base;
        ___tile_sub_layer_wall = _data.wall;
    }
    
    static get_tile_sub_layer_base = function()
    {
        return ___tile_sub_layer_base;
    }
    
    static get_tile_sub_layer_wall = function()
    {
        return ___tile_sub_layer_wall;
    }
    
    static set_tile_bottom_layer = function(_data)
    {
        ___tile_bottom_layer_base = _data.base;
        ___tile_bottom_layer_wall = _data.wall;
    }
    
    static get_tile_bottom_layer_base = function()
    {
        return ___tile_bottom_layer_base;
    }
    
    static get_tile_bottom_layer_wall = function()
    {
        return ___tile_bottom_layer_wall;
    }
    
    static set_tile_foliage = function(_chance, _tile)
    {
        ___tile_foliage_chance = _chance;
        ___tile_foliage_tile = choose_weighted_parse(_tile);
    }
    
    static get_tile_foliage_chance = function()
    {
        return ___tile_foliage_chance;
    }
    
    static get_tile_foliage_tile = function()
    {
        return ___tile_foliage_tile;
    }
}