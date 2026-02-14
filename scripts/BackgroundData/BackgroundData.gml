enum BACKGROUND_TYPE {
    PARALLAX,
    TILE
}

function BackgroundData(_type) constructor
{
    ___type = _type;
    ___blend = 0;
    ___sprites = [];
    ___widths = [];
    ___heights = [];
    ___xoffset = 0;
    ___yoffset = 0;
    
    static set_blend = function(_blend)
    {
        ___blend = _blend;
        return self;
    }
    
    static add_sprite = function(_sprite, _width, _height)
    {
        array_push(___sprites, _sprite);
        array_push(___widths, _width);
        array_push(___heights, _height);
        return self;
    }
    
    static set_sprite_offset = function(_xoffset, _yoffset)
    {
        ___xoffset = _xoffset;
        ___yoffset = _yoffset;
        return self;
    }
    
    static get_type = function() { return ___type; }
    
    static get_sprite_count = function()
    {
        return array_length(___sprites);
    }
    
    static get_sprite = function(_index)
    {
        return ___sprites[_index];
    }
    
    static get_width = function(_index)
    {
        return ___widths[_index];
    }
    
    static get_height = function(_index)
    {
        return ___heights[_index];
    }
}
