/* UI textbox element - interactive text input */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width textbox width */
/* @param {real} _height textbox height */
function UITextbox(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor
{
    text = "";
    
    placeholder = "";
    
    text_length = 256;
    
    
    /* "string", "integer", "numeric", "uppercase", "alphanumeric", "letters" */
    mode = "string";
    
    
    background_color = #1a1a2a;
    
    border_color = #3a3a4a;
    
    focus_border_color = #4a8aff;
    
    text_color = c_white;
    
    placeholder_color = #6a6a7a;
    
    
    /* state bitmask (aligned with MENU_BUTTON_BOOLEAN) */
    boolean = MENU_BUTTON_BOOLEAN.IS_VISIBLE;
    
    
    cursor_blink = 0;
    
    
    static update = function()
    {
        if !(visible) exit;
        
        
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
        
        
        var _is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        
        if (_is_hovered)
        {
            boolean |= MENU_BUTTON_BOOLEAN.IS_HOVER;
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
            {
                boolean ^= MENU_BUTTON_BOOLEAN.IS_HOVER;
            }
        }
        
        
        if (mouse_check_button_pressed(mb_left))
        {
            var _was_focused = (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED);
            
            
            if (_is_hovered) && !(global.ui_input_consumed)
            {
                if !(_was_focused)
                {
                    boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                    
                    global.ui_input_consumed = true;
                    
                    keyboard_string = text;
                    
                    emit_event("on_focus");
                }
            }
            else
            {
                if (_was_focused)
                {
                    boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                    
                    emit_event("on_blur");
                    
                    emit_event("on_change", { value: text });
                }
            }
        }
        
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            ++cursor_blink;
            
            if (cursor_blink >= 60)
            {
                cursor_blink = 0;
            }
            
            
            var _new_text = keyboard_string;
            
            
            /* filtering logic */
            switch (mode)
            {
                case "integer":
                    var _filtered = "";
                    var _len = string_length(_new_text);
                    
                    for (var i = 1; i <= _len; ++i)
                    {
                        var _c = string_char_at(_new_text, i);
                        
                        if (_c >= "0" && _c <= "9") || (_c == "-" && i == 1)
                        {
                            _filtered += _c;
                        }
                    }
                    _new_text = _filtered;
                    break;
                    
                case "numeric":
                    var _filtered = "";
                    var _has_dot = false;
                    var _len = string_length(_new_text);
                    
                    for (var i = 1; i <= _len; ++i)
                    {
                        var _c = string_char_at(_new_text, i);
                        
                        if (_c >= "0" && _c <= "9")
                        {
                            _filtered += _c;
                        }
                        else if (_c == "-" && i == 1)
                        {
                            _filtered += _c;
                        }
                        else if (_c == "." && !(_has_dot))
                        {
                            _filtered += _c;
                            _has_dot = true;
                        }
                    }
                    _new_text = _filtered;
                    break;
                    
                case "uppercase":
                    _new_text = string_upper(_new_text);
                    break;
                    
                case "alphanumeric":
                    var _filtered = "";
                    var _len = string_length(_new_text);
                    
                    for (var i = 1; i <= _len; ++i)
                    {
                        var _c = string_char_at(_new_text, i);
                        
                        if (_c >= "a" && _c <= "z") || (_c >= "A" && _c <= "Z") || (_c >= "0" && _c <= "9")
                        {
                            _filtered += _c;
                        }
                    }
                    _new_text = _filtered;
                    break;
                    
                case "letters":
                    var _filtered = "";
                    var _len = string_length(_new_text);
                    
                    for (var i = 1; i <= _len; ++i)
                    {
                        var _c = string_char_at(_new_text, i);
                        
                        if (_c >= "a" && _c <= "z") || (_c >= "A" && _c <= "Z")
                        {
                            _filtered += _c;
                        }
                    }
                    _new_text = _filtered;
                    break;
            }
            
            
            if (string_length(_new_text) > text_length)
            {
                _new_text = string_copy(_new_text, 1, text_length);
            }
            
            
            if (_new_text != text)
            {
                text = _new_text;
                
                keyboard_string = text;
                
                emit_event("on_input", { value: text });
            }
            
            
            if (keyboard_check_pressed(vk_enter))
            {
                boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                
                emit_event("on_submit", { value: text });
            }
        }
        
        
        /* update bindings */
        update_bindings();
        
        
        /* update children */
        var _child_count = array_length(children);
        
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            children[i].update();
        }
    }
    
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _base_scale = ui_get_base_scale();
        
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        
        draw_rectangle_colour(_x1, _y1, _x2, _y2, background_color, background_color, background_color, background_color, false);
        
        
        var _is_focused = (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED);
        
        var _b_color = (_is_focused ? focus_border_color : border_color);
        
        draw_rectangle_colour(_x1, _y1, _x2, _y2, _b_color, _b_color, _b_color, _b_color, true);
        
        
        var _display_text = (text != "") ? text : placeholder;
        var _display_color = (text != "") ? text_color : placeholder_color;
        
        
        var _prev_halign = draw_get_halign();
        var _prev_valign = draw_get_valign();
        
        draw_set_align(fa_left, fa_middle);
        
        
        var _text_x = _x1 + 4 * _base_scale_x;
        var _text_y = (_y1 + _y2) / 2;
        
        
        render_text(_text_x, _text_y, _display_text, _base_scale_x * 0.8, _base_scale_y * 0.8, 0, _display_color, 1);
        
        
        if (_is_focused) && (cursor_blink < 30)
        {
            var _cursor_x = _text_x + string_width(text) * _base_scale_x * 0.4;
            
            draw_line_colour(_cursor_x, _y1 + 4, _cursor_x, _y2 - 4, text_color, text_color);
        }
        
        
        draw_set_align(_prev_halign, _prev_valign);
    }
    
    
    static set_value = function(_value)
    {
        text = string(_value);
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            keyboard_string = text;
        }
        
        return self;
    }
    
    
    static get_value = function()
    {
        if (mode == "integer")
        {
            return (text != "") ? real(text) : 0;
        }
        
        return text;
    }
}
