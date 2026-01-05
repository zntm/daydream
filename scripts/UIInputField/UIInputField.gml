/// @description UIInputField - A text input component
/// @param {String} _id Optional unique identifier
/// @param {String} _text Initial text content
/// @param {String} _placeholder Placeholder text when empty

function UIInputField(_id = "", _text = "", _placeholder = "") : UIBox(_id) constructor
{
    text = _text;
    placeholder = _placeholder;
    
    // Cursor state
    cursor_position = string_length(_text);
    selection_start = -1;
    selection_end = -1;
    
    cursor_blink_time = 0;
    cursor_visible = true;
    cursor_blink_rate = 0.5; // seconds
    
    // Input state
    is_editing = false;
    
    // Sizing
    field_width = 200;
    field_height = 28;
    
    width = field_width;
    height = field_height;
    width_mode = UI_SIZE_MODE.FIXED;
    height_mode = UI_SIZE_MODE.FIXED;
    
    // Styling
    text_colour = c_white;
    placeholder_colour = c_gray;
    text_scale = 1;
    cursor_colour = c_white;
    selection_colour = make_colour_rgb(80, 120, 180);
    
    // Validation
    max_length = 256;
    allowed_chars = ""; // Empty = all allowed
    numeric_only = false;
    
    // Callbacks
    on_change = undefined;
    on_submit = undefined;
    
    // Focusable
    focusable = true;
    
    // Default styling
    background_colour = make_colour_rgb(30, 30, 40);
    border_colour = make_colour_rgb(60, 60, 80);
    border_width = 1;
    corner_radius = 4;
    
    padding_left = 8;
    padding_right = 8;
    padding_top = 4;
    padding_bottom = 4;
    
    // Scroll offset for long text
    scroll_offset = 0;
    
    // --- Fluent Setters ---
    
    static set_text = function(_text)
    {
        var _old_text = text;
        text = string_copy(_text, 1, max_length);
        cursor_position = clamp(cursor_position, 0, string_length(text));
        
        if (text != _old_text && on_change != undefined)
        {
            on_change(self, text);
        }
        return self;
    }
    
    static get_text = function()
    {
        return text;
    }
    
    static set_placeholder = function(_placeholder)
    {
        placeholder = _placeholder;
        return self;
    }
    
    static set_max_length = function(_max)
    {
        max_length = _max;
        if (string_length(text) > max_length)
        {
            text = string_copy(text, 1, max_length);
        }
        return self;
    }
    
    static set_numeric_only = function(_numeric)
    {
        numeric_only = _numeric;
        return self;
    }
    
    static set_allowed_chars = function(_chars)
    {
        allowed_chars = _chars;
        return self;
    }
    
    static set_field_size = function(_width, _height)
    {
        field_width = _width;
        field_height = _height;
        width = _width;
        height = _height;
        return self;
    }
    
    static set_on_change = function(_callback)
    {
        on_change = _callback;
        return self;
    }
    
    static set_on_submit = function(_callback)
    {
        on_submit = _callback;
        return self;
    }
    
    static start_editing = function()
    {
        is_editing = true;
        keyboard_string = "";
        cursor_blink_time = 0;
        cursor_visible = true;
        return self;
    }
    
    static stop_editing = function()
    {
        is_editing = false;
        selection_start = -1;
        selection_end = -1;
        return self;
    }
    
    static select_all = function()
    {
        selection_start = 0;
        selection_end = string_length(text);
        cursor_position = selection_end;
        return self;
    }
    
    // --- Helpers ---
    
    static _is_char_allowed = function(_char)
    {
        if (numeric_only)
        {
            return string_pos(_char, "0123456789.-") > 0;
        }
        if (allowed_chars != "")
        {
            return string_pos(_char, allowed_chars) > 0;
        }
        return ord(_char) >= 32; // Printable characters
    }
    
    static _insert_text = function(_new_text)
    {
        // Delete selection first
        if (selection_start >= 0 && selection_end >= 0 && selection_start != selection_end)
        {
            var _sel_min = min(selection_start, selection_end);
            var _sel_max = max(selection_start, selection_end);
            text = string_copy(text, 1, _sel_min) + string_copy(text, _sel_max + 1, string_length(text) - _sel_max);
            cursor_position = _sel_min;
            selection_start = -1;
            selection_end = -1;
        }
        
        // Filter allowed chars
        var _filtered = "";
        for (var i = 1; i <= string_length(_new_text); ++i)
        {
            var _char = string_char_at(_new_text, i);
            if (_is_char_allowed(_char))
            {
                _filtered += _char;
            }
        }
        
        // Check max length
        var _available = max_length - string_length(text);
        if (string_length(_filtered) > _available)
        {
            _filtered = string_copy(_filtered, 1, _available);
        }
        
        if (_filtered != "")
        {
            var _old_text = text;
            text = string_copy(text, 1, cursor_position) + _filtered + string_copy(text, cursor_position + 1, string_length(text) - cursor_position);
            cursor_position += string_length(_filtered);
            
            if (text != _old_text && on_change != undefined)
            {
                on_change(self, text);
            }
        }
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        return field_width - padding_left - padding_right;
    }
    
    static get_content_height = function()
    {
        return field_height - padding_top - padding_bottom;
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Update cursor blink
        if (is_editing)
        {
            cursor_blink_time += global.delta_time;
            if (cursor_blink_time >= cursor_blink_rate)
            {
                cursor_visible = !cursor_visible;
                cursor_blink_time = 0;
            }
            
            // Process keyboard input
            if (keyboard_string != "")
            {
                _insert_text(keyboard_string);
                keyboard_string = "";
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            // Handle special keys
            if (keyboard_check_pressed(vk_backspace))
            {
                if (selection_start >= 0 && selection_start != selection_end)
                {
                    _insert_text(""); // Delete selection
                }
                else if (cursor_position > 0)
                {
                    var _old_text = text;
                    text = string_copy(text, 1, cursor_position - 1) + string_copy(text, cursor_position + 1, string_length(text) - cursor_position);
                    cursor_position--;
                    
                    if (text != _old_text && on_change != undefined)
                    {
                        on_change(self, text);
                    }
                }
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            if (keyboard_check_pressed(vk_delete))
            {
                if (selection_start >= 0 && selection_start != selection_end)
                {
                    _insert_text(""); // Delete selection
                }
                else if (cursor_position < string_length(text))
                {
                    var _old_text = text;
                    text = string_copy(text, 1, cursor_position) + string_copy(text, cursor_position + 2, string_length(text) - cursor_position - 1);
                    
                    if (text != _old_text && on_change != undefined)
                    {
                        on_change(self, text);
                    }
                }
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            if (keyboard_check_pressed(vk_left))
            {
                if (keyboard_check(vk_shift))
                {
                    if (selection_start < 0) selection_start = cursor_position;
                    cursor_position = max(0, cursor_position - 1);
                    selection_end = cursor_position;
                }
                else
                {
                    selection_start = -1;
                    selection_end = -1;
                    cursor_position = max(0, cursor_position - 1);
                }
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            if (keyboard_check_pressed(vk_right))
            {
                if (keyboard_check(vk_shift))
                {
                    if (selection_start < 0) selection_start = cursor_position;
                    cursor_position = min(string_length(text), cursor_position + 1);
                    selection_end = cursor_position;
                }
                else
                {
                    selection_start = -1;
                    selection_end = -1;
                    cursor_position = min(string_length(text), cursor_position + 1);
                }
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            if (keyboard_check_pressed(vk_home))
            {
                cursor_position = 0;
                selection_start = -1;
                selection_end = -1;
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            if (keyboard_check_pressed(vk_end))
            {
                cursor_position = string_length(text);
                selection_start = -1;
                selection_end = -1;
                cursor_blink_time = 0;
                cursor_visible = true;
            }
            
            // Ctrl+A select all
            if (keyboard_check(vk_control) && keyboard_check_pressed(ord("A")))
            {
                select_all();
            }
            
            // Enter to submit
            if (keyboard_check_pressed(vk_enter))
            {
                stop_editing();
                if (on_submit != undefined)
                {
                    on_submit(self, text);
                }
            }
            
            // Escape to cancel
            if (keyboard_check_pressed(vk_escape))
            {
                stop_editing();
            }
        }
        
        if (on_update != undefined) on_update(self);
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    // --- Input Handling ---
    
    static handle_input = function(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released)
    {
        if (!visible || !enabled) return undefined;
        
        var _hovered = point_in_bounds(_mouse_x, _mouse_y);
        var _previous_state = state;
        
        if (_hovered)
        {
            if (_previous_state == UI_STATE.NORMAL)
            {
                if (on_hover_enter != undefined) on_hover_enter(self);
            }
            
            if (_mouse_pressed)
            {
                state = UI_STATE.PRESSED;
                start_editing();
                // TODO: Set cursor position based on click position
                cursor_position = string_length(text);
                if (on_press != undefined) on_press(self);
            }
            else if (!_mouse_held)
            {
                if (is_editing || global.ui_manager.focused_element == self)
                {
                    state = UI_STATE.FOCUSED;
                }
                else
                {
                    state = UI_STATE.HOVER;
                }
            }
        }
        else
        {
            if (_previous_state == UI_STATE.HOVER || _previous_state == UI_STATE.PRESSED)
            {
                if (on_hover_exit != undefined) on_hover_exit(self);
            }
            
            if (_mouse_pressed && is_editing)
            {
                stop_editing();
            }
            
            if (is_editing || global.ui_manager.focused_element == self)
            {
                state = UI_STATE.FOCUSED;
            }
            else
            {
                state = UI_STATE.NORMAL;
            }
        }
        
        return (_hovered && focusable) ? self : undefined;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Update styling based on state
        if (!enabled)
        {
            background_colour = make_colour_rgb(25, 25, 30);
            border_colour = make_colour_rgb(40, 40, 50);
        }
        else if (is_editing)
        {
            background_colour = make_colour_rgb(35, 35, 50);
            border_colour = make_colour_rgb(100, 140, 200);
        }
        else if (state == UI_STATE.HOVER || state == UI_STATE.FOCUSED)
        {
            background_colour = make_colour_rgb(35, 35, 45);
            border_colour = (state == UI_STATE.FOCUSED) ? c_white : make_colour_rgb(80, 80, 100);
        }
        else
        {
            background_colour = make_colour_rgb(30, 30, 40);
            border_colour = make_colour_rgb(60, 60, 80);
        }
        
        // Draw background
        draw_background();
        
        var _text_x = _abs_x + padding_left - scroll_offset;
        var _text_y = _abs_y + field_height / 2;
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        // Draw selection
        if (is_editing && selection_start >= 0 && selection_end >= 0 && selection_start != selection_end)
        {
            var _sel_min = min(selection_start, selection_end);
            var _sel_max = max(selection_start, selection_end);
            
            var _sel_start_x = _text_x + string_length(string_copy(text, 1, _sel_min)) * 6 * text_scale;
            var _sel_end_x = _text_x + string_length(string_copy(text, 1, _sel_max)) * 6 * text_scale;
            
            draw_set_colour(selection_colour);
            draw_set_alpha(0.5);
            draw_rectangle(_sel_start_x, _abs_y + padding_top, _sel_end_x, _abs_y + field_height - padding_bottom, false);
        }
        
        // Draw text or placeholder
        if (text != "")
        {
            draw_set_colour(enabled ? text_colour : c_gray);
            draw_set_alpha(1);
            render_text(_text_x, _text_y, text, text_scale, text_scale);
        }
        else if (placeholder != "" && !is_editing)
        {
            draw_set_colour(placeholder_colour);
            draw_set_alpha(0.6);
            render_text(_text_x, _text_y, placeholder, text_scale, text_scale);
        }
        
        // Draw cursor
        if (is_editing && cursor_visible)
        {
            var _cursor_x = _text_x + string_length(string_copy(text, 1, cursor_position)) * 6 * text_scale;
            
            draw_set_colour(cursor_colour);
            draw_set_alpha(1);
            draw_line_width(_cursor_x, _abs_y + padding_top + 2, _cursor_x, _abs_y + field_height - padding_bottom - 2, 1);
        }
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(c_white);
        draw_set_alpha(1);
    }
}
