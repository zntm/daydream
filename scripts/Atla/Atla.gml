function Atla(_xoffset, _yoffset, _width, _height, _number) constructor
{
    ___value =
        (_number            << 44) |
        (_height            << 33) |
        (_width             << 22) |
        ((_yoffset + 1024)  << 11) |
        ((_xoffset + 1024)  << 0);
    
    static set_sprite_index = function(_sprite_index, _index)
    {
        self[$ "___sprites_indeces"] ??= [];
        
        ___sprites_indeces[@ _index] = _sprite_index;
        ___sprites_indeces_length = array_length(___sprites_indeces);
        
        return self;
    }
    
    static get_sprite_indeces = function()
    {
        return ___sprites_indeces;
    }
    
    static get_sprite_indeces_length = function()
    {
        return ___sprites_indeces_length;
    }
    
    static get_sprite_index = function(_index)
    {
        return ___sprites_indeces[_index % get_sprite_indeces_length()];
    }
    
    static get_xoffset = function()
    {
        return ((___value >> 0) & 2047) - 1024;
    }
    
    static get_yoffset = function()
    {
        return ((___value >> 11) & 2047) - 1024;
    }
    
    static get_width = function()
    {
        return (___value >> 22) & 2047;
    }
    
    static get_height = function()
    {
        return (___value >> 33) & 2047;
    }
    
    static get_number = function()
    {
        return (___value >> 44) & 2047;
    }
    
    static set_is_rotated = function()
    {
        ___is_rotated = true;
        
        return self;
    }
    
    static is_rotated = function()
    {
        return self[$ "___is_rotated"] ?? false;
    }
}