/// @description UIText - Text display component using cuteify rendering
/// @param {String} _id Optional unique identifier
/// @param {String} _text Initial text content

function UIText(_id = "", _text = "") : UIElement(_id) constructor
{
    text = _text;
    text_colour = c_white;
    text_alpha = 1;
    text_scale = 1;
    
    halign = fa_left;
    valign = fa_top;
    
    // Cached text dimensions
    _cached_text = "";
    _cached_width = 0;
    _cached_height = 0;
    
    // --- Fluent Setters ---
    
    static set_text = function(_text)
    {
        text = _text;
        return self;
    }
    
    static set_text_colour = function(_colour)
    {
        text_colour = _colour;
        return self;
    }
    
    static set_text_alpha = function(_alpha)
    {
        text_alpha = _alpha;
        return self;
    }
    
    static set_text_scale = function(_scale)
    {
        text_scale = _scale;
        return self;
    }
    
    static set_text_align = function(_halign, _valign = fa_top)
    {
        halign = _halign;
        valign = _valign;
        return self;
    }
    
    // --- Content Size Calculation ---
    
    static get_content_width = function()
    {
        _update_text_cache();
        return _cached_width * text_scale;
    }
    
    static get_content_height = function()
    {
        _update_text_cache();
        return _cached_height * text_scale;
    }
    
    static _update_text_cache = function()
    {
        if (_cached_text != text)
        {
            _cached_text = text;
            // Use a base character height estimate (14px per line for safety)
            _cached_width = string_length(text) * 10; // Approximate width per character
            _cached_height = 14; // Base character height
        }
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        if (text == "") return;
        
        var _abs_x = get_absolute_x() + padding_left;
        var _abs_y = get_absolute_y() + padding_top;
        
        var _inner_w = _computed_width - padding_left - padding_right;
        var _inner_h = _computed_height - padding_top - padding_bottom;
        
        // Adjust position based on alignment
        switch (halign)
        {
            case fa_center: _abs_x += _inner_w / 2; break;
            case fa_right: _abs_x += _inner_w; break;
        }
        
        switch (valign)
        {
            case fa_middle: _abs_y += _inner_h / 2; break;
            case fa_bottom: _abs_y += _inner_h; break;
        }
        
        draw_set_halign(halign);
        draw_set_valign(valign);
        
        // Draw shadow
        draw_set_colour(c_black);
        draw_set_alpha(text_alpha * 0.25);
        render_text(_abs_x, _abs_y + text_scale, text, text_scale, text_scale);
        
        // Draw main text
        draw_set_colour(text_colour);
        draw_set_alpha(text_alpha);
        render_text(_abs_x, _abs_y, text, text_scale, text_scale);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
}
