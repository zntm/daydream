/// @desc UI Text Element - displays text with optional binding
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {String} _text Initial text
function UIText(_x, _y, _text = "") : UIElement(_x, _y, 0, 0) constructor {
    text = _text;
    colour = c_white;
    alpha = 1;
    text_scale = 1;
    halign = fa_left;
    valign = fa_top;
    
    static set_text = function(_text) {
        text = _text;
        return self;
    }
    
    static draw_content = function() {
        if (text == "") return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _scale_x = _base_scale.x * scale * text_scale;
        var _scale_y = _base_scale.y * scale * text_scale;
        
        var _prev_halign = draw_get_halign();
        var _prev_valign = draw_get_valign();
        draw_set_align(halign, valign);
        
        draw_text_cuteify(
            _abs_x * _base_scale.x,
            _abs_y * _base_scale.y,
            text,
            _scale_x,
            _scale_y,
            0,
            colour,
            alpha
        );
        
        draw_set_align(_prev_halign, _prev_valign);
    }
}
