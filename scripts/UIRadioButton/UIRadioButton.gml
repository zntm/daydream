/// @desc UI Radio Button Element - exclusive selection option
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {String} _text Label text
function UIRadioButton(_x, _y, _text = "") : UIElement(_x, _y, 100, 20) constructor {
    text = _text;
    value = ""; // The value this button represents
    group = ""; // Radio group name
    selected = false;
    
    // Visual styling
    circle_size = 8;
    circle_color = #3a3a4a;
    selected_color = #4a8aff;
    text_color = c_white;
    
    // Hover state
    is_hovered = false;
    
    static update = function() {
        if (!visible) exit;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        if (is_hovered && mouse_check_button_pressed(mb_left)) {
            if (!selected) {
                selected = true;
                emit_event("on_select", { value: value, group: group });
                sfx_play("phantasia:sfx/ui/click", global.settings.audio_sfx);
            }
        }
        
        update_bindings();
    }
    
    static draw_content = function() {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        var _circle_x = (_abs_x + circle_size) * _base_scale_x;
        var _circle_y = (_abs_y + height / 2) * _base_scale_y;
        var _radius = circle_size * _base_scale_x;
        
        // Draw outer circle
        draw_circle_colour(_circle_x, _circle_y, _radius, circle_color, circle_color, false);
        
        // Draw selected indicator
        if (selected) {
            draw_circle_colour(_circle_x, _circle_y, _radius * 0.6, selected_color, selected_color, false);
        }
        
        // Draw text
        if (text != "") {
            var _text_x = (_abs_x + circle_size * 2 + 8) * _base_scale_x;
            var _text_y = _circle_y;
            
            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();
            draw_set_align(fa_left, fa_middle);
            
            render_text(
                _text_x, _text_y,
                text,
                _base_scale_x * 0.8,
                _base_scale_y * 0.8,
                0,
                text_color,
                1
            );
            
            draw_set_align(_prev_halign, _prev_valign);
        }
    }
    
    /// @desc Deselect this radio button (called when another in group is selected)
    static deselect = function() {
        selected = false;
        return self;
    }
}
