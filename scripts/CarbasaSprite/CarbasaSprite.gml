function CarbasaSprite(_page, _name, _sprite, _index, _xoffset, _yoffset, _width, _height) constructor
{
    ___page = _page;
    ___name = _name;
    
    static get_name = function()
    {
        return ___name;
    }
    
    ___xoffset = _xoffset;
    
    static get_xoffset = function()
    {
        return ___xoffset;
    }
    
    ___yoffset = _yoffset;
    
    static get_yoffset = function()
    {
        return ___yoffset;
    }
    
    ___sprite = _sprite;
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    ___index = _index;
    
    static get_index = function()
    {
        return ___index;
    }
    
    static set_position = function(_x, _y)
    {
        ___x = _x;
        ___y = _y;
        
        return self;
    }
    
    static get_x = function()
    {
        return ___x;
    }
    
    static get_y = function()
    {
        return ___y;
    }
    
    ___width = _width;
    
    static get_width = function()
    {
        return ___width;
    }
    
    ___height = _height;
    
    static get_height = function()
    {
        return ___height;
    }
}