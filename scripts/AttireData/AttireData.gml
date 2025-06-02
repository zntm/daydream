function AttireData(_name, _index, _type, _icon) constructor
{
    static set_icon = function(_icon)
    {
        ___icon = _icon;
        
        return self;
    }
    
    static get_icon = function()
    {
        return self[$ "___icon"] ?? spr_Null;
    }
    
    static set_sprite_colour = function(_sprite)
    {
        ___sprite_colour = _sprite;
        
        if (is_array(_sprite))
        {
            ___sprite_colour_length = array_length(_sprite);
        }
        
        return self;
    }
    
    static get_sprite_colour = function()
    {
        return self[$ "___sprite_colour"];
    }
    
    static get_sprite_colour_length = function()
    {
        return self[$ "___sprite_colour_length"];
    }
    
    static set_sprite_white = function(_sprite)
    {
        ___sprite_white = _sprite;
        
        if (is_array(_sprite))
        {
            ___sprite_white_length = array_length(_sprite);
        }
        
        return self;
    }
    
    static get_sprite_white = function()
    {
        return self[$ "___sprite_white"];
    }
    
    static get_sprite_white_length = function()
    {
        return self[$ "___sprite_white_length"];
    }
}