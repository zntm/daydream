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
    ___sprite_width  = [];
    ___sprite_height = [];
    
    ___sprite_length = 0;
    
    static add_sprite = function(_sprite)
    {
        array_push(___sprite, _sprite);
        
        ++___sprite_length;
        
        return self;
    }
    
    static get_sprite = function(_index)
    {
        return ___sprite[_index];
    }
    
    static set_sprite_size = function(_index, _width, _height)
    {
        ___sprite_width[@ _index]  = _width;
        ___sprite_height[@ _index] = _height;
        
        return self;
    }
    
    static get_sprite_width = function(_index)
    {
        return ___sprite_width[_index];
    }
    
    static get_sprite_height = function(_index)
    {
        return ___sprite_height[_index];
    }
    
    static get_sprite_length = function()
    {
        return ___sprite_length;
    }
}