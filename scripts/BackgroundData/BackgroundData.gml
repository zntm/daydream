enum BACKGROUND_TYPE {
    PARALLAX,
    TILE
}

function BackgroundData(_type) constructor
{
    static __background_type = {
        "parallax": BACKGROUND_TYPE.PARALLAX,
        "tile": BACKGROUND_TYPE.TILE,
    }
    
    ___type = __background_type[$ _type];
    
    static get_type = function()
    {
        return ___type;
    }
    
    ___sprite = [];
    ___sprite_size = [];
    
    ___sprite_length = 0;
    
    static add_sprite = function(_sprite, _width, _height)
    {
        array_push(___sprite, _sprite);
        array_push(___sprite_size, (_height << 16) | _width);
        
        ++___sprite_length;
        
        return self;
    }
    
    static get_sprite = function(_index)
    {
        return ___sprite[_index];
    }
    
    static get_sprite_width = function(_index)
    {
        return ___sprite_size[_index] & 0xffff;
    }
    
    static get_sprite_height = function(_index)
    {
        return (___sprite_size[_index] >> 16) & 0xffff;
    }
    
    static get_sprite_length = function()
    {
        return ___sprite_length;
    }
}