/// @description GUI Text component - displays text using cuteify rendering
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {String} _text Initial text to display

function GUIText(_x, _y, _text = "") : GUIComponent(_x, _y, 0, 0) constructor
{
    text = _text;
    colour = c_white;
    alpha = 1;
    asset_prefix = "";
    text_scale = 1;
    
    static set_text = function(_text)
    {
        text = _text;
        return self;
    }
    
    static get_text = function()
    {
        return text;
    }
    
    static set_colour = function(_colour)
    {
        colour = _colour;
        return self;
    }
    
    static set_alpha = function(_alpha)
    {
        alpha = _alpha;
        return self;
    }
    
    static set_asset_prefix = function(_prefix)
    {
        asset_prefix = _prefix;
        return self;
    }
    
    static set_text_scale = function(_scale)
    {
        text_scale = _scale;
        return self;
    }
    
    static draw_content = function()
    {
        if (text == "") return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _scale_x = _base_scale_x * scale * text_scale;
        var _scale_y = _base_scale_y * scale * text_scale;
        
        draw_text_cuteify(
            _abs_x * _base_scale_x,
            _abs_y * _base_scale_y,
            text,
            _scale_x,
            _scale_y,
            0,
            colour,
            alpha,
            asset_prefix
        );
    }
}
