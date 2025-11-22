function AttireData(_icon, _colour, _white) constructor
{
    ___icon = _icon;
    
    // Handle colour - can be a single sprite ID or an array of sprite IDs
    if (is_array(_colour))
    {
        var _length = array_length(_colour);
        ___sprite_colour = array_create(_length);
        ___sprite_colour_length = _length;
        
        for (var i = 0; i < _length; ++i)
        {
            ___sprite_colour[@ i] = global.sprite_asset[$ _colour[i]];
        }
    }
    else
    {
        ___sprite_colour = global.sprite_asset[$ _colour];
    }
    
    // Handle white - can be a single sprite ID, an array of sprite IDs, or undefined
    if (_white != undefined)
    {
        if (is_array(_white))
        {
            var _length = array_length(_white);
            ___sprite_white = array_create(_length);
            ___sprite_white_length = _length;
            
            for (var i = 0; i < _length; ++i)
            {
                ___sprite_white[@ i] = global.sprite_asset[$ _white[i]];
            }
        }
        else
        {
            ___sprite_white = global.sprite_asset[$ _white];
        }
    }
    
    static get_icon = function()
    {
        return self[$ "___icon"] ?? spr_Null;
    }
    
    static get_sprite_colour = function()
    {
        return self[$ "___sprite_colour"];
    }
    
    static get_sprite_colour_length = function()
    {
        return self[$ "___sprite_colour_length"];
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