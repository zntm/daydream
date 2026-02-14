<<<<<<< HEAD
/// @description UIButton - Interactive button component
/// @param {String} _id Optional unique identifier
/// @param {String} _text Button label text

function UIButton(_id = "", _text = "") : UIBox(_id) constructor
{
    text = _text;
    text_colour = c_white;
    text_scale = 1;
    
    // State-based styling
    normal_colour = make_colour_rgb(60, 60, 80);
    hover_colour = make_colour_rgb(80, 80, 120);
    pressed_colour = make_colour_rgb(40, 40, 60);
    disabled_colour = make_colour_rgb(40, 40, 40);
    
    normal_border = make_colour_rgb(100, 100, 140);
    hover_border = make_colour_rgb(140, 140, 200);
    
    // Make buttons focusable by default
    focusable = true;
    
    // Default padding
    padding_left = 12;
    padding_right = 12;
    padding_top = 8;
    padding_bottom = 8;
    
    // Default border
    border_width = 1;
    border_colour = normal_border;
    corner_radius = 4;
    
    // --- Fluent Setters ---
    
    static set_button_text = function(_text)
    {
        text = _text;
        return self;
    }
    
    static set_text_colour = function(_colour)
    {
        text_colour = _colour;
        return self;
    }
    
    static set_text_scale = function(_scale)
    {
        text_scale = _scale;
        return self;
    }
    
    static set_normal_colour = function(_bg, _border = undefined)
    {
        normal_colour = _bg;
        if (_border != undefined) normal_border = _border;
        return self;
    }
    
    static set_hover_colour = function(_bg, _border = undefined)
    {
        hover_colour = _bg;
        if (_border != undefined) hover_border = _border;
        return self;
    }
    
    static set_pressed_colour = function(_bg)
    {
        pressed_colour = _bg;
        return self;
    }
    
    static set_disabled_colour = function(_bg)
    {
        disabled_colour = _bg;
        return self;
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        return string_length(text) * 6 * text_scale;
    }
    
    static get_content_height = function()
    {
        return 8 * text_scale;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        // Update colours based on state
        if (!enabled)
        {
            background_colour = disabled_colour;
            border_colour = disabled_colour;
        }
        else
        {
            // Sync visual state with input for focused buttons
            var _is_pressed = (state == UI_STATE.PRESSED) || 
                              (state == UI_STATE.FOCUSED && (keyboard_check(vk_enter) || keyboard_check(vk_space) || gamepad_button_check(0, gp_face1)));
            
            if (_is_pressed)
            {
                background_colour = pressed_colour;
                border_colour = hover_border;
            }
            else
            {
                switch (state)
                {
                    case UI_STATE.NORMAL:
                        background_colour = normal_colour;
                        border_colour = normal_border;
                        break;
                    case UI_STATE.HOVER:
                        background_colour = hover_colour;
                        border_colour = hover_border;
                        break;
                    case UI_STATE.FOCUSED:
                        background_colour = hover_colour; // Same bg as hover
                        border_colour = c_white; // Distinct bright border for focus
                        break;
                }
            }
        }
        
        // Draw box background
        draw_background();
        
        // Draw text
        if (text != "")
        {
            var _abs_x = get_absolute_x() + _computed_width / 2;
            var _abs_y = get_absolute_y() + _computed_height / 2;
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Draw shadow
            draw_set_colour(c_black);
            draw_set_alpha(0.3);
            render_text(_abs_x, _abs_y + text_scale, text, text_scale, text_scale);
            
            // Draw main text
            draw_set_colour(enabled ? text_colour : c_gray);
            draw_set_alpha(1);
            render_text(_abs_x, _abs_y, text, text_scale, text_scale);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_colour(c_white);
=======
/// @desc UI Button Element - interactive button with click events
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Button width
/// @param {Real} _height Button height
/// @param {String} _text Button text
function UIButton(_x, _y, _width, _height, _text = "") : UIElement(_x, _y, _width, _height) constructor {
    text = _text;
    colour = c_white;
    text_scale = 1;
    
    // Button states
    is_hovered = false;
    is_pressed = false;
    is_disabled = false;
    
    // Visual styling
    normal_color = #3a3a4a;
    hover_color = #4a4a5a;
    pressed_color = #2a2a3a;
    disabled_color = #2a2a2a;
    border_color = #5a5a6a;
    
    static update = function() {
        if (!visible || is_disabled) return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        var _was_hovered = is_hovered;
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        if (is_hovered) {
            if (mouse_check_button_pressed(mb_left)) {
                is_pressed = true;
                emit_event("on_select_press");
            }
            
            if (mouse_check_button_released(mb_left) && is_pressed) {
                is_pressed = false;
                emit_event("on_select_release");
                sfx_play("phantasia:sfx/ui/click", global.settings.audio_sfx);
            }
        } else {
            if (mouse_check_button_released(mb_left)) {
                is_pressed = false;
            }
        }
        
        // Update bindings
        update_bindings();
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
    }
    
    static draw_content = function() {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        // Determine background color
        var _bg_color = normal_color;
        if (is_disabled) {
            _bg_color = disabled_color;
        } else if (is_pressed) {
            _bg_color = pressed_color;
        } else if (is_hovered) {
            _bg_color = hover_color;
        }
        
        // Draw background
        draw_rectangle_colour(_x1, _y1, _x2, _y2, _bg_color, _bg_color, _bg_color, _bg_color, false);
        
        // Draw border
        draw_rectangle_colour(_x1, _y1, _x2, _y2, border_color, border_color, border_color, border_color, true);
        
        // Draw text centered
        if (text != "") {
            var _cx = (_x1 + _x2) / 2;
            var _cy = (_y1 + _y2) / 2;
            
            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();
            draw_set_align(fa_center, fa_middle);
            
            draw_text_cuteify(
                _cx, _cy,
                text,
                _base_scale_x * text_scale,
                _base_scale_y * text_scale,
                0,
                colour,
                1
            );
            
            draw_set_align(_prev_halign, _prev_valign);
>>>>>>> region
        }
    }
}
