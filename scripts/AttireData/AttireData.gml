function AttireData(_icon, _colour, _white) constructor
{
    ___icon = _icon;
    ___sprite_colour = global.sprite_asset[$ _colour];
    
    if (is_array(_colour))
    {
        ___sprite_colour_length = array_length(_colour);
    }
    
    if (_white != undefined)
    {
        ___sprite_white = global.sprite_asset[$ _white];
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