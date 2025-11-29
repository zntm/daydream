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
            // Get the asset from global.sprite_asset
            // The asset itself may be an array of SpriteAssets (when sprites are in a folder)
            // or a single SpriteAsset
            ___sprite_colour[@ i] = global.sprite_asset[$ _colour[i]];
        }
    }
    else
    {
        // Get the asset from global.sprite_asset
        // The asset itself may be an array of SpriteAssets (when sprites are in a folder)
        // or a single SpriteAsset
        ___sprite_colour = global.sprite_asset[$ _colour];
        
        // If the asset is an array (multi-part attire like shirt with 3 parts), track length
        if (is_array(___sprite_colour))
        {
            ___sprite_colour_length = array_length(___sprite_colour);
        }
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
                // Get the asset from global.sprite_asset
                // The asset itself may be an array of SpriteAssets (when sprites are in a folder)
                // or a single SpriteAsset
                ___sprite_white[@ i] = global.sprite_asset[$ _white[i]];
            }
        }
        else
        {
            // Get the asset from global.sprite_asset
            // The asset itself may be an array of SpriteAssets (when sprites are in a folder)
            // or a single SpriteAsset
            ___sprite_white = global.sprite_asset[$ _white];
            
            // If the asset is an array (multi-part attire like shirt with 3 parts), track length
            if (is_array(___sprite_white))
            {
                ___sprite_white_length = array_length(___sprite_white);
            }
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