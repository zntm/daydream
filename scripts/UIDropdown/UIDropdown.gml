/// @description UIDropdown - A dropdown select component
/// @param {String} _id Optional unique identifier
/// @param {Array} _options Array of option strings or {text, value} structs
/// @param {Real} _selected_index Initial selected index

function UIDropdown(_id = "", _options = [], _selected_index = 0) : UIBox(_id) constructor
{
    options = _options;
    selected_index = clamp(_selected_index, 0, max(0, array_length(_options) - 1));
    
    // Display state
    is_open = false;
    hover_index = -1;
    
    // Sizing
    dropdown_width = 150;
    dropdown_height = 28;
    option_height = 24;
    max_visible_options = 6;
    
    width = dropdown_width;
    height = dropdown_height;
    width_mode = UI_SIZE_MODE.FIXED;
    height_mode = UI_SIZE_MODE.FIXED;
    
    // Styling
    text_colour = c_white;
    text_scale = 1;
    
    arrow_colour = c_white;
    
    option_bg_colour = make_colour_rgb(40, 40, 60);
    option_hover_colour = make_colour_rgb(60, 60, 100);
    option_selected_colour = make_colour_rgb(80, 80, 140);
    
    // Callbacks
    on_change = undefined;
    
    // Focusable
    focusable = true;
    
    // Animation
    open_progress = 0;
    animation_speed = 0.2;
    
    // Default styling
    background_colour = make_colour_rgb(50, 50, 70);
    border_colour = make_colour_rgb(80, 80, 120);
    border_width = 1;
    corner_radius = 4;
    
    padding_left = 8;
    padding_right = 24; // Space for arrow
    
    // --- Fluent Setters ---
    
    static set_options = function(_options)
    {
        options = _options;
        selected_index = clamp(selected_index, 0, max(0, array_length(_options) - 1));
        return self;
    }
    
    static add_option = function(_option)
    {
        array_push(options, _option);
        return self;
    }
    
    static set_selected_index = function(_index)
    {
        var _old_index = selected_index;
        selected_index = clamp(_index, 0, max(0, array_length(options) - 1));
        
        if (selected_index != _old_index && on_change != undefined)
        {
            on_change(self, selected_index, get_selected_value());
        }
        return self;
    }
    
    static get_selected_index = function()
    {
        return selected_index;
    }
    
    static get_selected_value = function()
    {
        if (array_length(options) == 0) return undefined;
        
        var _opt = options[selected_index];
        if (is_struct(_opt) && struct_exists(_opt, "value"))
        {
            return _opt.value;
        }
        return _opt;
    }
    
    static get_selected_text = function()
    {
        if (array_length(options) == 0) return "";
        
        var _opt = options[selected_index];
        if (is_struct(_opt) && struct_exists(_opt, "text"))
        {
            return _opt.text;
        }
        return string(_opt);
    }
    
    static set_on_change = function(_callback)
    {
        on_change = _callback;
        return self;
    }
    
    static set_dropdown_size = function(_width, _height, _option_height = 24)
    {
        dropdown_width = _width;
        dropdown_height = _height;
        option_height = _option_height;
        width = _width;
        height = _height;
        return self;
    }
    
    static set_max_visible = function(_count)
    {
        max_visible_options = _count;
        return self;
    }
    
    static open = function()
    {
        is_open = true;
        hover_index = selected_index;
        return self;
    }
    
    static close = function()
    {
        is_open = false;
        hover_index = -1;
        return self;
    }
    
    static toggle_open = function()
    {
        if (is_open) close();
        else open();
        return self;
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        return dropdown_width - padding_left - padding_right;
    }
    
    static get_content_height = function()
    {
        return dropdown_height - padding_top - padding_bottom;
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Animate open/close
        var _target = is_open ? 1 : 0;
        open_progress = lerp(open_progress, _target, animation_speed);
        
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
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _hovered_main = point_in_bounds(_mouse_x, _mouse_y);
        var _previous_state = state;
        
        // Handle dropdown list interaction
        if (is_open && open_progress > 0.5)
        {
            var _option_count = min(array_length(options), max_visible_options);
            var _list_height = _option_count * option_height;
            var _list_y = _abs_y + dropdown_height;
            
            var _in_list = (_mouse_x >= _abs_x && _mouse_x <= _abs_x + dropdown_width &&
                            _mouse_y >= _list_y && _mouse_y <= _list_y + _list_height);
            
            if (_in_list)
            {
                hover_index = floor((_mouse_y - _list_y) / option_height);
                hover_index = clamp(hover_index, 0, array_length(options) - 1);
                
                if (_mouse_pressed)
                {
                    set_selected_index(hover_index);
                    close();
                    sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                    return self;
                }
                
                return self;
            }
            else if (_mouse_pressed)
            {
                // Clicked outside, close dropdown
                close();
            }
        }
        
        // Handle main button interaction
        if (_hovered_main)
        {
            if (_previous_state == UI_STATE.NORMAL)
            {
                if (on_hover_enter != undefined) on_hover_enter(self);
            }
            
            if (_mouse_pressed)
            {
                state = UI_STATE.PRESSED;
                if (on_press != undefined) on_press(self);
            }
            else if (_mouse_released && _previous_state == UI_STATE.PRESSED)
            {
                toggle_open();
                if (global.ui_manager.focused_element == self) state = UI_STATE.FOCUSED;
                else state = UI_STATE.HOVER;
                
                if (on_click != undefined) on_click(self);
                sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
            }
            else if (!_mouse_held)
            {
                if (global.ui_manager.focused_element == self)
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
            
            if (global.ui_manager.focused_element == self)
            {
                state = UI_STATE.FOCUSED;
            }
            else
            {
                state = UI_STATE.NORMAL;
            }
        }
        
        // Handle keyboard/gamepad when focused
        if (state == UI_STATE.FOCUSED)
        {
            if (is_open)
            {
                if (keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu))
                {
                    hover_index = max(0, hover_index - 1);
                }
                if (keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd))
                {
                    hover_index = min(array_length(options) - 1, hover_index + 1);
                }
                if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1))
                {
                    set_selected_index(hover_index);
                    close();
                }
                if (keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_face2))
                {
                    close();
                }
            }
            else
            {
                if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1))
                {
                    open();
                }
                if (keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0, gp_padl))
                {
                    set_selected_index(selected_index - 1);
                }
                if (keyboard_check_pressed(vk_right) || gamepad_button_check_pressed(0, gp_padr))
                {
                    set_selected_index(selected_index + 1);
                }
            }
        }
        
        return (_hovered_main && focusable) ? self : undefined;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Update background colour based on state
        if (!enabled)
        {
            background_colour = make_colour_rgb(40, 40, 40);
        }
        else if (state == UI_STATE.PRESSED || is_open)
        {
            background_colour = make_colour_rgb(60, 60, 90);
        }
        else if (state == UI_STATE.HOVER || state == UI_STATE.FOCUSED)
        {
            background_colour = make_colour_rgb(55, 55, 80);
        }
        else
        {
            background_colour = make_colour_rgb(50, 50, 70);
        }
        
        border_colour = (state == UI_STATE.FOCUSED) ? c_white : make_colour_rgb(80, 80, 120);
        
        // Draw main button background
        draw_background();
        
        // Draw selected text
        var _text = get_selected_text();
        if (_text != "")
        {
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_colour(enabled ? text_colour : c_gray);
            draw_set_alpha(1);
            
            render_text(_abs_x + padding_left, _abs_y + dropdown_height / 2, _text, text_scale, text_scale);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        
        // Draw arrow
        var _arrow_x = _abs_x + dropdown_width - 16;
        var _arrow_y = _abs_y + dropdown_height / 2;
        var _arrow_rot = lerp(0, 180, open_progress);
        
        draw_set_colour(arrow_colour);
        draw_set_alpha(enabled ? 1 : 0.5);
        
        // Simple triangle arrow
        var _arrow_size = 4;
        draw_triangle(
            _arrow_x - _arrow_size, _arrow_y - _arrow_size / 2,
            _arrow_x + _arrow_size, _arrow_y - _arrow_size / 2,
            _arrow_x, _arrow_y + _arrow_size / 2,
            false
        );
        
        draw_set_colour(c_white);
        draw_set_alpha(1);
    }
    
    // --- Draw Override (for dropdown list) ---
    
    static draw = function()
    {
        if (!visible) return;
        
        draw_self_content();
        
        // Draw dropdown list
        if (open_progress > 0.01)
        {
            var _abs_x = get_absolute_x();
            var _abs_y = get_absolute_y();
            var _option_count = array_length(options);
            var _visible_count = min(_option_count, max_visible_options);
            var _list_height = _visible_count * option_height * open_progress;
            var _list_y = _abs_y + dropdown_height;
            
            // Draw list background
            draw_set_colour(option_bg_colour);
            draw_set_alpha(0.95);
            draw_roundrect_ext(_abs_x, _list_y, _abs_x + dropdown_width, _list_y + _list_height, corner_radius, corner_radius, false);
            
            // Draw border
            draw_set_colour(border_colour);
            draw_set_alpha(0.8);
            draw_roundrect_ext(_abs_x, _list_y, _abs_x + dropdown_width, _list_y + _list_height, corner_radius, corner_radius, true);
            
            // Set clipping for animation
            var _prev_scissor = gpu_get_scissor();
            gpu_set_scissor(_abs_x, _list_y, dropdown_width, _list_height);
            
            // Draw options
            for (var i = 0; i < _visible_count; ++i)
            {
                var _opt_y = _list_y + i * option_height;
                
                // Option background
                if (i == hover_index)
                {
                    draw_set_colour(option_hover_colour);
                    draw_set_alpha(1);
                    draw_rectangle(_abs_x + 2, _opt_y, _abs_x + dropdown_width - 2, _opt_y + option_height, false);
                }
                else if (i == selected_index)
                {
                    draw_set_colour(option_selected_colour);
                    draw_set_alpha(0.5);
                    draw_rectangle(_abs_x + 2, _opt_y, _abs_x + dropdown_width - 2, _opt_y + option_height, false);
                }
                
                // Option text
                var _opt = options[i];
                var _opt_text = is_struct(_opt) && struct_exists(_opt, "text") ? _opt.text : string(_opt);
                
                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_colour(text_colour);
                draw_set_alpha(1);
                
                render_text(_abs_x + padding_left, _opt_y + option_height / 2, _opt_text, text_scale, text_scale);
            }
            
            // Restore scissor
            if (array_length(_prev_scissor) >= 4)
            {
                gpu_set_scissor(_prev_scissor[0], _prev_scissor[1], _prev_scissor[2], _prev_scissor[3]);
            }
            else
            {
                gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
            }
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_colour(c_white);
            draw_set_alpha(1);
        }
        
        // Draw children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].draw();
        }
    }
}
