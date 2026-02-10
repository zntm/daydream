/// @desc UI Textbox Element - text input field
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Textbox width
/// @param {Real} _height Textbox height
function UITextbox(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    text = "";
    placeholder = "";
    max_length = 256;
    
    // Input mode
    mode = "string"; // "string" or "integer"
    
    // Visual styling
    background_color = #1a1a2a;
    border_color = #3a3a4a;
    focus_border_color = #4a8aff;
    text_color = c_white;
    placeholder_color = #6a6a7a;
    
    // State
    is_focused = false;
    cursor_pos = 0;
    cursor_blink = 0;
    
    static update = function() {
        if (!visible) return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_height / global.resolution_height_reference);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        // Focus handling
        if (mouse_check_button_pressed(mb_left)) {
            var _was_focused = is_focused;
            is_focused = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
            
            if (is_focused && !_was_focused) {
                keyboard_string = text;
                emit_event("on_focus");
            } else if (!is_focused && _was_focused) {
                emit_event("on_blur");
                emit_event("on_change", { value: text });
            }
        }
        
        // Text input when focused
        if (is_focused) {
            cursor_blink = (cursor_blink + 1) % 60;
            
            var _new_text = keyboard_string;
            
            // Apply mode restrictions
            if (mode == "integer") {
                var _filtered = "";
                for (var i = 1; i <= string_length(_new_text); i++) {
                    var _c = string_char_at(_new_text, i);
                    if ((_c >= "0" && _c <= "9") || (_c == "-" && i == 1)) {
                        _filtered += _c;
                    }
                }
                _new_text = _filtered;
            }
            
            // Apply max length
            if (string_length(_new_text) > max_length) {
                _new_text = string_copy(_new_text, 1, max_length);
            }
            
            if (_new_text != text) {
                text = _new_text;
                keyboard_string = text;
                emit_event("on_input", { value: text });
            }
            
            // Enter key
            if (keyboard_check_pressed(vk_enter)) {
                is_focused = false;
                emit_event("on_submit", { value: text });
            }
        }
        
        update_bindings();
    }
    
    static draw_content = function() {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_height / global.resolution_height_reference);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        // Draw background
        draw_rectangle_colour(_x1, _y1, _x2, _y2, 
            background_color, background_color, background_color, background_color, false);
        
        // Draw border
        var _b_color = is_focused ? focus_border_color : border_color;
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            _b_color, _b_color, _b_color, _b_color, true);
        
        // Draw text or placeholder
        var _display_text = (text != "") ? text : placeholder;
        var _display_color = (text != "") ? text_color : placeholder_color;
        
        var _prev_halign = draw_get_halign();
        var _prev_valign = draw_get_valign();
        draw_set_align(fa_left, fa_middle);
        
        var _text_x = _x1 + 4 * _base_scale_x;
        var _text_y = (_y1 + _y2) / 2;
        
        draw_text_cuteify(
            _text_x, _text_y,
            _display_text,
            _base_scale_x * 0.8,
            _base_scale_y * 0.8,
            0,
            _display_color,
            1
        );
        
        // Draw cursor when focused
        if (is_focused && cursor_blink < 30) {
            var _cursor_x = _text_x + string_width(text) * _base_scale_x * 0.4;
            draw_line_colour(_cursor_x, _y1 + 4, _cursor_x, _y2 - 4, text_color, text_color);
        }
        
        draw_set_align(_prev_halign, _prev_valign);
    }
    
    /// @desc Set the text value
    static set_value = function(_value) {
        text = string(_value);
        if (is_focused) {
            keyboard_string = text;
        }
        return self;
    }
    
    /// @desc Get the current value
    static get_value = function() {
        if (mode == "integer") {
            return (text != "") ? real(text) : 0;
        }
        return text;
    }
}
